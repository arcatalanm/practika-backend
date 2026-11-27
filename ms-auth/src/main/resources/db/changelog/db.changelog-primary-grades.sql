--liquibase formatted sql

--changeset practika:auth-017-enforce-first-second-grade
--validCheckSum: 9:a7694385f13549985527a63a8bd50fc0
-- Datos
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:2 SELECT COUNT(*) FROM niveles_educativos WHERE codigo IN ('1° Básico','2° Básico')
UPDATE niveles_educativos SET activo=0 WHERE codigo NOT IN ('1° Básico','2° Básico');
UPDATE secciones s JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo
SET s.activo=0 WHERE n.activo=0 OR n.codigo NOT IN ('1° Básico','2° Básico') OR s.id_seccion_canonica IS NOT NULL;
UPDATE matriculas m JOIN secciones s ON s.id_seccion=m.id_seccion
JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo
SET m.activa=0,m.fecha_fin=GREATEST(CURRENT_TIMESTAMP(6),m.fecha_inicio)
WHERE m.activa=1 AND n.codigo NOT IN ('1° Básico','2° Básico');
ALTER TABLE niveles_educativos ADD CONSTRAINT chk_niveles_primarios_activos
CHECK (activo=0 OR codigo IN ('1° Básico','2° Básico'));

--changeset practika:auth-018-stable-primary-section-references context:@dev
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:2 SELECT COUNT(*) FROM secciones s JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo WHERE s.id_seccion_canonica IS NULL AND n.codigo IN ('1° Básico','2° Básico')
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM secciones s JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo WHERE (s.id_seccion=910001 AND n.codigo<>'1° Básico') OR (s.id_seccion=910002 AND n.codigo<>'2° Básico') OR (s.id_seccion IN (910001,910002) AND s.id_seccion_canonica IS NOT NULL)
CREATE TEMPORARY TABLE secciones_iniciales AS
SELECT s.id_seccion AS id_anterior, n.id_nivel_educativo,
       CASE n.codigo WHEN '1° Básico' THEN 910001 ELSE 910002 END AS id_nueva,
       s.activo
FROM secciones s
JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo
WHERE s.id_seccion_canonica IS NULL AND n.codigo IN ('1° Básico','2° Básico');

UPDATE secciones s JOIN secciones_iniciales m ON m.id_anterior=s.id_seccion
SET s.id_seccion_canonica=s.id_seccion, s.activo=0
WHERE s.id_seccion<>m.id_nueva;

INSERT INTO secciones (id_seccion,id_nivel_educativo,activo)
SELECT m.id_nueva,m.id_nivel_educativo,m.activo FROM secciones_iniciales m
WHERE NOT EXISTS (SELECT 1 FROM secciones s WHERE s.id_seccion=m.id_nueva);

UPDATE secciones s JOIN secciones_iniciales m ON m.id_nivel_educativo=s.id_nivel_educativo
SET s.id_seccion_canonica=m.id_nueva, s.activo=0
WHERE s.id_seccion<>m.id_nueva;

UPDATE usuarios u
JOIN secciones s ON s.id_seccion=u.id_seccion
JOIN secciones_iniciales m ON m.id_nivel_educativo=s.id_nivel_educativo
SET u.id_seccion=m.id_nueva;

UPDATE matriculas matricula
JOIN secciones s ON s.id_seccion=matricula.id_seccion
JOIN secciones_iniciales m ON m.id_nivel_educativo=s.id_nivel_educativo
SET matricula.id_seccion_origen=COALESCE(matricula.id_seccion_origen,matricula.id_seccion),
    matricula.id_seccion=m.id_nueva
WHERE matricula.id_seccion<>m.id_nueva;

UPDATE matriculas m JOIN usuarios u ON u.run=m.run_estudiante
JOIN roles r ON r.id_rol=u.id_rol
SET m.activa=0,m.fecha_fin=GREATEST(CURRENT_TIMESTAMP(6),m.fecha_inicio)
WHERE m.activa=1 AND r.codigo='ESTUDIANTE' AND u.activo=1
  AND u.id_seccion IN (910001,910002) AND m.id_seccion<>u.id_seccion;

INSERT INTO matriculas (run_estudiante,id_seccion,fecha_inicio,activa,origen)
SELECT u.run,u.id_seccion,CURRENT_TIMESTAMP(6),1,'MIGRACION'
FROM usuarios u JOIN roles r ON r.id_rol=u.id_rol
WHERE u.activo=1 AND r.codigo='ESTUDIANTE' AND u.id_seccion IN (910001,910002)
  AND NOT EXISTS (SELECT 1 FROM matriculas m WHERE m.run_estudiante=u.run AND m.activa=1);

DROP TEMPORARY TABLE secciones_iniciales;
