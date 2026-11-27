import argparse
import base64
import hashlib
import json
import os
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

import pymysql
from pymysql.cursors import DictCursor


def conectar(servicio):
    return pymysql.connect(
        host=os.getenv(f'DB_{servicio.upper()}_HOST', os.getenv('DB_HOST', '127.0.0.1')),
        port=int(os.getenv(f'DB_{servicio.upper()}_PORT', os.getenv('DB_PORT', '3306'))),
        user=os.getenv('DB_USERNAME', 'root'), password=os.getenv('DB_PASSWORD', ''),
        database=os.getenv(f'DB_{servicio.upper()}_SCHEMA',
                           os.getenv('DB_SCHEMA_PREFIX', 'practika_xampp') + '_' + servicio),
        charset='utf8mb4', cursorclass=DictCursor, autocommit=False,
        connect_timeout=5,
    )


def consultar(conexion, sql, parametros=()):
    with conexion.cursor() as cursor:
        cursor.execute(sql, parametros)
        return cursor.fetchall()


def ejecutar(conexion, sql, parametros=()):
    with conexion.cursor() as cursor:
        cursor.execute(sql, parametros)
        return cursor.lastrowid


def serializar(valor):
    if isinstance(valor, (datetime, date)):
        return valor.isoformat()
    if isinstance(valor, Decimal):
        return float(valor)
    if isinstance(valor, bytes):
        return {'base64': base64.b64encode(valor).decode('ascii')}
    raise TypeError(type(valor).__name__)


def respaldar(conexiones):
    tablas = {'academic': ('cursos_portal', 'docentes_cursos_portal'),
              'content': ('unidades_cursos', 'evaluaciones_asignadas')}
    datos = {servicio: {tabla: consultar(conexiones[servicio], f'SELECT * FROM {tabla}')
                       for tabla in nombres} for servicio, nombres in tablas.items()}
    destino = Path(__file__).resolve().parents[1] / '.migration-backups' / (
        'cursos-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    destino.mkdir(parents=True)
    (destino / 'datos.json').write_text(json.dumps(datos, default=serializar, ensure_ascii=False), encoding='utf-8')
    return destino


def contenido(conexion, evaluacion):
    preguntas = consultar(conexion, '''SELECT p.*, t.codigo AS tipo FROM preguntas p
        JOIN tipos_pregunta t ON t.id_tipo_pregunta=p.id_tipo_pregunta
        WHERE p.id_evaluacion=%s ORDER BY p.id_pregunta''', (evaluacion['id_evaluacion'],))
    if not preguntas:
        raise ValueError(f"Evaluación sin preguntas: {evaluacion['id_evaluacion']}")
    resultado = []
    for pregunta in preguntas:
        opciones = consultar(conexion, 'SELECT * FROM opciones WHERE id_pregunta=%s ORDER BY id_opcion',
                             (pregunta['id_pregunta'],))
        resultado.append({'id': pregunta['id_pregunta'], 'texto': pregunta['texto_pregunta'],
                          'tipo': pregunta['tipo'], 'puntajeMaximo': pregunta['puntaje_maximo'],
                          'opciones': [{'id': o['id_opcion'], 'texto': o['texto_alternativa'],
                                        'esCorrecta': bool(o['es_correcta'])} for o in opciones],
                          'materiales': []})
    materiales = consultar(conexion, '''SELECT COUNT(*) AS total FROM materiales m
        LEFT JOIN preguntas p ON p.id_pregunta=m.id_pregunta
        WHERE m.activo=1 AND (m.id_evaluacion=%s OR p.id_evaluacion=%s)''',
                           (evaluacion['id_evaluacion'], evaluacion['id_evaluacion']))
    if materiales[0]['total']:
        raise ValueError('El catálogo inicial contiene adjuntos; publica esas evaluaciones desde la aplicación')
    return json.dumps({'titulo': evaluacion['titulo'], 'cantidadIntentos': evaluacion['cantidad_intentos'],
                       'fechaAplicacion': evaluacion['fecha_aplicacion'], 'preguntas': resultado,
                       'materiales': []}, default=serializar, ensure_ascii=False, separators=(',', ':'))


def migrar(conexiones):
    auth, academic, content = (conexiones[s] for s in ('auth', 'academic', 'content'))
    secciones = consultar(auth, '''SELECT s.id_seccion FROM secciones s
        JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo
        WHERE s.activo=1 AND s.id_seccion_canonica IS NULL AND n.activo=1
        AND n.codigo IN ('1° Básico','2° Básico') ORDER BY s.id_seccion''')
    if len(secciones) != 2:
        raise ValueError('Se requieren las dos secciones activas de Primero y Segundo básico')
    ids = {s['id_seccion'] for s in secciones}
    personas = consultar(auth, '''SELECT u.run,u.email,u.id_seccion,r.codigo AS rol FROM usuarios u
        JOIN roles r ON r.id_rol=u.id_rol WHERE u.activo=1 AND r.codigo IN ('ESTUDIANTE','PROFESOR')''')
    for persona in personas:
        if persona['id_seccion'] not in ids:
            raise ValueError(f"Asigna una sección primaria a {persona['email']} antes de migrar")
        if persona['rol'] == 'ESTUDIANTE':
            matricula = consultar(auth, '''SELECT id_seccion FROM matriculas
                WHERE run_estudiante=%s AND activa=1''', (persona['run'],))
            if len(matricula) != 1 or matricula[0]['id_seccion'] != persona['id_seccion']:
                raise ValueError(f"Matrícula inconsistente: {persona['email']}")
    especialidades = consultar(academic, 'SELECT * FROM docentes_asignaturas')
    unidades = consultar(content, '''SELECT * FROM unidades WHERE activo=1
        AND id_unidad BETWEEN 910001 AND 910016 ORDER BY id_unidad''')
    evaluaciones = consultar(content, '''SELECT e.* FROM evaluaciones e JOIN unidades u ON u.id_unidad=e.id_unidad
        WHERE e.estado_activo=1 AND u.activo=1 AND u.id_unidad BETWEEN 910001 AND 910016
        ORDER BY e.id_evaluacion''')
    snapshots = {e['id_evaluacion']: contenido(content, e) for e in evaluaciones}
    materias = consultar(academic, 'SELECT * FROM asignaturas WHERE activo=1 ORDER BY id_asignatura')
    atendidos = set()
    cursos = []
    for seccion in secciones:
        for materia in materias:
            docentes = [p['run'] for p in personas if p['rol'] == 'PROFESOR' and any(
                d['run_profesor'] == p['run'] and d['id_asignatura'] == materia['id_asignatura']
                and (d['ambos_basicos'] or p['id_seccion'] == seccion['id_seccion']) for d in especialidades)]
            if not docentes:
                raise ValueError(f"Falta docente para sección {seccion['id_seccion']}, asignatura {materia['id_asignatura']}")
            atendidos.update(docentes)
            ejecutar(academic, '''INSERT INTO cursos_portal (id_seccion,id_asignatura,nombre,activo)
                VALUES (%s,%s,%s,1) ON DUPLICATE KEY UPDATE activo=1''',
                     (seccion['id_seccion'], materia['id_asignatura'], materia['nombre_materia']))
            curso = consultar(academic, '''SELECT id_curso_portal FROM cursos_portal
                WHERE id_seccion=%s AND id_asignatura=%s AND id_periodo_academico IS NULL''',
                              (seccion['id_seccion'], materia['id_asignatura']))[0]['id_curso_portal']
            cursos.append(curso)
            for docente in docentes:
                ejecutar(academic, '''INSERT INTO docentes_cursos_portal (id_curso_portal,run_profesor)
                    VALUES (%s,%s) ON DUPLICATE KEY UPDATE run_profesor=VALUES(run_profesor)''', (curso, docente))
            seleccionadas = [u for u in unidades if u['id_asignatura'] == materia['id_asignatura']]
            if not seleccionadas:
                raise ValueError(f"Faltan unidades para {materia['nombre_materia']}")
            for unidad in seleccionadas:
                ejecutar(content, '''INSERT INTO unidades_cursos
                    (id_unidad,id_curso_portal,run_profesor,publicacion_inicializada)
                    VALUES (%s,%s,%s,1) ON DUPLICATE KEY UPDATE publicacion_inicializada=1''',
                         (unidad['id_unidad'], curso, min(docentes)))
                asignacion = consultar(content, '''SELECT id_asignacion FROM unidades_cursos
                    WHERE id_unidad=%s AND id_curso_portal=%s''', (unidad['id_unidad'], curso))[0]['id_asignacion']
                propias = [e for e in evaluaciones if e['id_unidad'] == unidad['id_unidad']]
                if {e['tipo'] for e in propias} != {'ACTIVIDAD', 'PRUEBA'}:
                    raise ValueError(f"Faltan actividades o pruebas en unidad {unidad['id_unidad']}")
                for evaluacion in propias:
                    eid = evaluacion['id_evaluacion']
                    versiones = consultar(content, '''SELECT version,activa FROM evaluaciones_asignadas
                        WHERE id_asignacion=%s AND id_evaluacion=%s FOR UPDATE''', (asignacion, eid))
                    if any(v['activa'] for v in versiones):
                        continue
                    snapshot = snapshots[eid]
                    ejecutar(content, '''INSERT INTO evaluaciones_asignadas
                        (id_asignacion,id_evaluacion,version,publicada_en,run_publicador,activa,huella_origen,contenido_snapshot)
                        VALUES (%s,%s,%s,CURRENT_TIMESTAMP(6),%s,1,%s,%s)''',
                             (asignacion, eid, max((v['version'] for v in versiones), default=0) + 1,
                              min(docentes), hashlib.sha256(snapshot.encode('utf-8')).hexdigest(), snapshot))
    if atendidos != {p['run'] for p in personas if p['rol'] == 'PROFESOR'}:
        raise ValueError('Hay profesores activos sin asignatura asociada')
    return {'estudiantes': sum(p['rol'] == 'ESTUDIANTE' for p in personas),
            'profesores': len(atendidos), 'cursos': len(cursos)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--aplicar', action='store_true')
    args = parser.parse_args()
    conexiones = {}
    try:
        for servicio in ('auth', 'academic', 'content'):
            conexiones[servicio] = conectar(servicio)
        if args.aplicar:
            print('Respaldo:', respaldar(conexiones))
        resultado = migrar(conexiones)
        for servicio in ('academic', 'content'):
            if args.aplicar:
                conexiones[servicio].commit()
        print('Aplicado:' if args.aplicar else 'Verificado sin guardar:', resultado)
    finally:
        for conexion in conexiones.values():
            conexion.rollback()
            conexion.close()


if __name__ == '__main__':
    main()
