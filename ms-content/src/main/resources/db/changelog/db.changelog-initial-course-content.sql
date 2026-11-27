--liquibase formatted sql

--changeset practika:content-069-primary-course-learning-content context:@dev
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:16 SELECT COUNT(*) FROM unidades WHERE activo=1 AND id_unidad BETWEEN 910001 AND 910016 AND id_asignatura IN (1,2,3,5)
--precondition-sql-check expectedResult:40 SELECT COUNT(*) FROM evaluaciones e JOIN unidades u ON u.id_unidad=e.id_unidad WHERE e.estado_activo=1 AND u.activo=1 AND u.id_unidad BETWEEN 910001 AND 910016 AND (e.id_evaluacion BETWEEN 920001 AND 920024 OR e.id_evaluacion BETWEEN 921001 AND 921016)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM evaluaciones e WHERE (e.id_evaluacion BETWEEN 920001 AND 920024 OR e.id_evaluacion BETWEEN 921001 AND 921016) AND NOT EXISTS (SELECT 1 FROM preguntas p WHERE p.id_evaluacion=e.id_evaluacion)
SET @practika_group_concat_max_len=@@SESSION.group_concat_max_len;
SET SESSION group_concat_max_len=16777216;

DELETE uc FROM unidades_cursos uc JOIN unidades u ON u.id_unidad=uc.id_unidad
WHERE u.id_unidad BETWEEN 1 AND 6 AND u.activo=0
  AND NOT EXISTS (SELECT 1 FROM evaluaciones_asignadas p WHERE p.id_asignacion=uc.id_asignacion);

CREATE TEMPORARY TABLE cursos_iniciales AS
SELECT 910000+g.grado*100+a.id_asignatura AS id_curso_portal,a.id_asignatura,
       CASE a.id_asignatura WHEN 1 THEN 12345679 WHEN 2 THEN 12345671 ELSE 12345682 END AS run_profesor
FROM (SELECT 1 AS grado UNION ALL SELECT 2) g
CROSS JOIN (SELECT 1 AS id_asignatura UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 5) a;

INSERT INTO unidades_cursos (id_unidad,id_curso_portal,run_profesor,publicacion_inicializada)
SELECT u.id_unidad,c.id_curso_portal,c.run_profesor,1
FROM cursos_iniciales c JOIN unidades u ON u.id_asignatura=c.id_asignatura
WHERE u.activo=1 AND u.id_unidad BETWEEN 910001 AND 910016
ON DUPLICATE KEY UPDATE publicacion_inicializada=1;

CREATE TEMPORARY TABLE publicaciones_iniciales_pendientes AS
SELECT uc.id_asignacion,e.id_evaluacion,
       COALESCE((SELECT MAX(p.version) FROM evaluaciones_asignadas p
                 WHERE p.id_asignacion=uc.id_asignacion AND p.id_evaluacion=e.id_evaluacion),0)+1 AS version
FROM unidades_cursos uc
JOIN cursos_iniciales c ON c.id_curso_portal=uc.id_curso_portal
JOIN unidades u ON u.id_unidad=uc.id_unidad AND u.id_asignatura=c.id_asignatura
JOIN evaluaciones e ON e.id_unidad=u.id_unidad
WHERE u.activo=1 AND e.estado_activo=1 AND u.id_unidad BETWEEN 910001 AND 910016
  AND (e.id_evaluacion BETWEEN 920001 AND 920024 OR e.id_evaluacion BETWEEN 921001 AND 921016)
  AND NOT EXISTS (SELECT 1 FROM evaluaciones_asignadas p
                  WHERE p.id_asignacion=uc.id_asignacion AND p.id_evaluacion=e.id_evaluacion AND p.activa=1);

INSERT INTO evaluaciones_asignadas
  (id_asignacion,id_evaluacion,version,publicada_en,run_publicador,activa,huella_origen,contenido_snapshot)
SELECT n.id_asignacion,n.id_evaluacion,n.version,CURRENT_TIMESTAMP(6),uc.run_profesor,1,'','{}'
FROM publicaciones_iniciales_pendientes n
JOIN unidades_cursos uc ON uc.id_asignacion=n.id_asignacion;

CREATE TEMPORARY TABLE publicaciones_iniciales AS
SELECT p.id_evaluacion_asignada,p.id_evaluacion
FROM evaluaciones_asignadas p JOIN publicaciones_iniciales_pendientes n
  ON n.id_asignacion=p.id_asignacion AND n.id_evaluacion=p.id_evaluacion AND n.version=p.version;

CREATE TEMPORARY TABLE archivos_iniciales AS
SELECT UUID() AS id,datos.* FROM (
    SELECT DISTINCT p.id_evaluacion_asignada,r.id AS id_original,r.nombre,r.tipo_contenido,r.ruta_archivo
    FROM publicaciones_iniciales p
    JOIN materiales m ON m.activo=1 AND (m.id_evaluacion=p.id_evaluacion
      OR EXISTS (SELECT 1 FROM preguntas q WHERE q.id_pregunta=m.id_pregunta AND q.id_evaluacion=p.id_evaluacion))
    JOIN archivos_recursos r ON m.contenido_url=CONCAT('/api/v1/content/recursos/archivos/',r.id)
) datos;

INSERT INTO archivos_evaluacion (id,id_evaluacion_asignada,nombre,tipo_contenido,ruta_archivo)
SELECT id,id_evaluacion_asignada,nombre,tipo_contenido,ruta_archivo FROM archivos_iniciales;

CREATE TEMPORARY TABLE materiales_iniciales AS
SELECT p.id_evaluacion_asignada,m.id_pregunta,m.id_material,
       JSON_OBJECT('id',m.id_material,'tipo',t.codigo,
                   'contenidoUrl',CASE WHEN a.id IS NULL THEN m.contenido_url
                                       ELSE CONCAT('/api/v1/content/recursos/evaluaciones/',a.id) END,
                   'activo',JSON_EXTRACT('true','$'),'titulo',m.titulo,'contenidoTexto',m.contenido_texto) AS contenido
FROM publicaciones_iniciales p
JOIN materiales m ON m.activo=1 AND (m.id_evaluacion=p.id_evaluacion
  OR EXISTS (SELECT 1 FROM preguntas q WHERE q.id_pregunta=m.id_pregunta AND q.id_evaluacion=p.id_evaluacion))
JOIN tipos_material t ON t.id_tipo_material=m.id_tipo_material
LEFT JOIN archivos_iniciales a ON a.id_evaluacion_asignada=p.id_evaluacion_asignada
  AND m.contenido_url=CONCAT('/api/v1/content/recursos/archivos/',a.id_original);

CREATE TEMPORARY TABLE materiales_preguntas_iniciales AS
SELECT id_evaluacion_asignada,id_pregunta,
       CONCAT('[',GROUP_CONCAT(contenido ORDER BY id_material SEPARATOR ','),']') AS contenido
FROM materiales_iniciales WHERE id_pregunta IS NOT NULL
GROUP BY id_evaluacion_asignada,id_pregunta;

CREATE TEMPORARY TABLE materiales_evaluaciones_iniciales AS
SELECT id_evaluacion_asignada,
       CONCAT('[',GROUP_CONCAT(contenido ORDER BY id_material SEPARATOR ','),']') AS contenido
FROM materiales_iniciales WHERE id_pregunta IS NULL GROUP BY id_evaluacion_asignada;

CREATE TEMPORARY TABLE opciones_iniciales AS
SELECT o.id_pregunta,
       CONCAT('[',GROUP_CONCAT(JSON_OBJECT('id',o.id_opcion,'texto',o.texto_alternativa,
                    'esCorrecta',JSON_EXTRACT(IF(o.es_correcta=1,'true','false'),'$'))
                    ORDER BY o.id_opcion SEPARATOR ','),']') AS contenido
FROM opciones o JOIN preguntas q ON q.id_pregunta=o.id_pregunta
WHERE q.id_evaluacion BETWEEN 920001 AND 920024 OR q.id_evaluacion BETWEEN 921001 AND 921016
GROUP BY o.id_pregunta;

CREATE TEMPORARY TABLE preguntas_iniciales AS
SELECT p.id_evaluacion_asignada,
       CONCAT('[',GROUP_CONCAT(JSON_OBJECT('id',q.id_pregunta,'texto',q.texto_pregunta,'tipo',t.codigo,
                                'puntajeMaximo',q.puntaje_maximo,
                                'opciones',JSON_EXTRACT(COALESCE(o.contenido,'[]'),'$'),
                                'materiales',JSON_EXTRACT(COALESCE(m.contenido,'[]'),'$'))
                                ORDER BY q.id_pregunta SEPARATOR ','),']') AS contenido
FROM publicaciones_iniciales p JOIN preguntas q ON q.id_evaluacion=p.id_evaluacion
JOIN tipos_pregunta t ON t.id_tipo_pregunta=q.id_tipo_pregunta
LEFT JOIN opciones_iniciales o ON o.id_pregunta=q.id_pregunta
LEFT JOIN materiales_preguntas_iniciales m
  ON m.id_evaluacion_asignada=p.id_evaluacion_asignada AND m.id_pregunta=q.id_pregunta
GROUP BY p.id_evaluacion_asignada;

UPDATE evaluaciones_asignadas p
JOIN publicaciones_iniciales n ON n.id_evaluacion_asignada=p.id_evaluacion_asignada
JOIN evaluaciones e ON e.id_evaluacion=p.id_evaluacion
JOIN preguntas_iniciales q ON q.id_evaluacion_asignada=p.id_evaluacion_asignada
LEFT JOIN materiales_evaluaciones_iniciales m ON m.id_evaluacion_asignada=p.id_evaluacion_asignada
SET p.contenido_snapshot=JSON_OBJECT('titulo',e.titulo,'cantidadIntentos',e.cantidad_intentos,
    'fechaAplicacion',DATE_FORMAT(e.fecha_aplicacion,'%Y-%m-%dT%H:%i:%s'),
    'preguntas',JSON_EXTRACT(q.contenido,'$'),'materiales',JSON_EXTRACT(COALESCE(m.contenido,'[]'),'$'));

UPDATE evaluaciones_asignadas p
JOIN publicaciones_iniciales n ON n.id_evaluacion_asignada=p.id_evaluacion_asignada
SET p.huella_origen=SHA2(p.contenido_snapshot,256);

DROP TEMPORARY TABLE preguntas_iniciales;
DROP TEMPORARY TABLE opciones_iniciales;
DROP TEMPORARY TABLE materiales_evaluaciones_iniciales;
DROP TEMPORARY TABLE materiales_preguntas_iniciales;
DROP TEMPORARY TABLE materiales_iniciales;
DROP TEMPORARY TABLE archivos_iniciales;
DROP TEMPORARY TABLE publicaciones_iniciales;
DROP TEMPORARY TABLE publicaciones_iniciales_pendientes;
DROP TEMPORARY TABLE cursos_iniciales;
SET SESSION group_concat_max_len=@practika_group_concat_max_len;
