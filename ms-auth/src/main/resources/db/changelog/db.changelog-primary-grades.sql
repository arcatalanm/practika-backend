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
