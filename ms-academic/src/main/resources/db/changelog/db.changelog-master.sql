--liquibase formatted sql

--changeset practika:academic-001-asignaturas
CREATE TABLE IF NOT EXISTS `asignaturas` (
  `id_asignatura` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_asignaturas` PRIMARY KEY (`id_asignatura`),
  `nombre_materia` VARCHAR(100) NOT NULL
);

--changeset practika:academic-002-objetivos
CREATE TABLE IF NOT EXISTS `objetivo_aprendizajes` (
  `id_aprendizaje` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_objetivo_aprendizajes` PRIMARY KEY (`id_aprendizaje`),
  `id_asignatura` INT NOT NULL,
  `descripcion_objetivo` TEXT NOT NULL
);

ALTER TABLE `objetivo_aprendizajes` ADD CONSTRAINT `fk_objetivo_aprendizajes_asignaturas` FOREIGN KEY (`id_asignatura`) REFERENCES `asignaturas` (`id_asignatura`) ON DELETE CASCADE;

--changeset practika:academic-100-dev-data context:@dev
INSERT INTO `asignaturas` (`id_asignatura`, `nombre_materia`) VALUES (1, 'Matemática');

INSERT INTO `asignaturas` (`id_asignatura`, `nombre_materia`) VALUES (2, 'Lenguaje y Comunicación');

INSERT INTO `asignaturas` (`id_asignatura`, `nombre_materia`) VALUES (3, 'Ciencias Naturales');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (1, 1, 'Representar y comparar fracciones propias e impropias en distintos contextos.');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (2, 1, 'Resolver problemas que involucren razones, proporciones y porcentajes.');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (3, 2, 'Analizar narraciones considerando personajes, ambiente, conflicto y secuencia.');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (4, 2, 'Planificar, escribir y revisar textos informativos para comunicar ideas con claridad.');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (5, 3, 'Explicar relaciones entre los sistemas del cuerpo humano y sus funciones.');

INSERT INTO `objetivo_aprendizajes` (`id_aprendizaje`, `id_asignatura`, `descripcion_objetivo`) VALUES (6, 3, 'Investigar cambios de estado de la materia mediante observaciones y modelos.');

--changeset practika:academic-003-asignaturas-activo
ALTER TABLE `asignaturas` ADD COLUMN `activo` BOOLEAN DEFAULT 1 NOT NULL;

--changeset practika:academic-004-course-ownership
--validCheckSum: 9:14f1ee6afedf0eb47c60f49dac69f7f0
-- Tablas
CREATE TABLE `periodos_academicos` (
  `id_periodo_academico` INT AUTO_INCREMENT PRIMARY KEY,
  `codigo` VARCHAR(20) NOT NULL,
  `nombre` VARCHAR(60) NOT NULL,
  `activo` BOOLEAN NOT NULL DEFAULT 1,
  CONSTRAINT `uq_periodos_academicos_codigo` UNIQUE (`codigo`)
);

CREATE TABLE `cursos_portal` (
  `id_curso_portal` INT AUTO_INCREMENT PRIMARY KEY,
  `id_seccion` INT NOT NULL,
  `id_asignatura` INT NULL,
  `id_periodo_academico` INT NOT NULL,
  `nombre` VARCHAR(120) NOT NULL,
  `descripcion` TEXT NULL,
  `activo` BOOLEAN NOT NULL DEFAULT 1,
  CONSTRAINT `uq_curso_portal_seccion_asignatura_periodo`
    UNIQUE (`id_seccion`, `id_asignatura`, `id_periodo_academico`),
  CONSTRAINT `fk_cursos_portal_periodos` FOREIGN KEY (`id_periodo_academico`)
    REFERENCES `periodos_academicos` (`id_periodo_academico`),
  CONSTRAINT `fk_cursos_portal_asignatura` FOREIGN KEY (`id_asignatura`)
    REFERENCES `asignaturas` (`id_asignatura`)
);

CREATE TABLE `docentes_cursos_portal` (
  `id_docente_curso` INT AUTO_INCREMENT PRIMARY KEY,
  `id_curso_portal` INT NOT NULL,
  `run_profesor` INT NOT NULL,
  CONSTRAINT `uq_docente_curso_portal` UNIQUE (`id_curso_portal`, `run_profesor`),
  CONSTRAINT `fk_docentes_cursos_portal_curso` FOREIGN KEY (`id_curso_portal`)
    REFERENCES `cursos_portal` (`id_curso_portal`)
);

--changeset practika:academic-005-objective-codes
ALTER TABLE objetivo_aprendizajes ADD COLUMN codigo VARCHAR(40) NULL;
UPDATE objetivo_aprendizajes SET codigo=CONCAT('OA-',id_asignatura,'-',id_aprendizaje);
ALTER TABLE objetivo_aprendizajes MODIFY codigo VARCHAR(40) NOT NULL;
ALTER TABLE objetivo_aprendizajes ADD CONSTRAINT uq_objetivo_codigo UNIQUE(codigo);

--changeset practika:academic-006-automatic-section-subjects
ALTER TABLE cursos_portal DROP FOREIGN KEY fk_cursos_portal_periodos;
ALTER TABLE cursos_portal MODIFY id_periodo_academico INT NULL;
ALTER TABLE cursos_portal ADD CONSTRAINT fk_cursos_portal_periodos FOREIGN KEY(id_periodo_academico) REFERENCES periodos_academicos(id_periodo_academico);
ALTER TABLE cursos_portal ADD COLUMN clave_seccion_asignatura VARCHAR(80) GENERATED ALWAYS AS (CASE WHEN id_periodo_academico IS NULL THEN CONCAT(id_seccion,':',id_asignatura) ELSE NULL END) STORED UNIQUE;

--changeset practika:academic-006b-mvp-history-stable-id context:@dev
--validCheckSum: 9:504af3c64762cd8fd1217dda8a8a5d0e
-- Inserts
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM asignaturas WHERE id_asignatura=5 AND nombre_materia<>'Historia' AND NOT EXISTS (SELECT 1 FROM asignaturas h WHERE h.nombre_materia='Historia')
INSERT INTO asignaturas (id_asignatura,nombre_materia,activo)
SELECT 5,'Historia',1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM asignaturas WHERE nombre_materia='Historia') AND NOT EXISTS (SELECT 1 FROM asignaturas WHERE id_asignatura=5);

--changeset practika:academic-007-mvp-subjects
UPDATE asignaturas SET nombre_materia = 'Lenguaje' WHERE nombre_materia = 'Lenguaje y Comunicación';
UPDATE asignaturas SET nombre_materia = 'Ciencias' WHERE nombre_materia = 'Ciencias Naturales';
INSERT INTO asignaturas (nombre_materia, activo)
SELECT 'Historia', 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM asignaturas WHERE nombre_materia = 'Historia');

--changeset practika:academic-008-mvp-starter-objectives
INSERT INTO objetivo_aprendizajes (id_asignatura, descripcion_objetivo, codigo)
SELECT a.id_asignatura, 'Contar, leer y comparar números hasta el 100.', 'OA-MAT-B1' FROM asignaturas a
WHERE a.nombre_materia = 'Matemática' AND NOT EXISTS (SELECT 1 FROM objetivo_aprendizajes WHERE codigo = 'OA-MAT-B1');
INSERT INTO objetivo_aprendizajes (id_asignatura, descripcion_objetivo, codigo)
SELECT a.id_asignatura, 'Leer y comprender palabras y oraciones simples.', 'OA-LEN-B1' FROM asignaturas a
WHERE a.nombre_materia = 'Lenguaje' AND NOT EXISTS (SELECT 1 FROM objetivo_aprendizajes WHERE codigo = 'OA-LEN-B1');
INSERT INTO objetivo_aprendizajes (id_asignatura, descripcion_objetivo, codigo)
SELECT a.id_asignatura, 'Ubicarse en el tiempo: días de la semana, meses y estaciones del año.', 'OA-HIS-B1' FROM asignaturas a
WHERE a.nombre_materia = 'Historia' AND NOT EXISTS (SELECT 1 FROM objetivo_aprendizajes WHERE codigo = 'OA-HIS-B1');
INSERT INTO objetivo_aprendizajes (id_asignatura, descripcion_objetivo, codigo)
SELECT a.id_asignatura, 'Reconocer los seres vivos y lo que necesitan para vivir.', 'OA-CIE-B1' FROM asignaturas a
WHERE a.nombre_materia = 'Ciencias' AND NOT EXISTS (SELECT 1 FROM objetivo_aprendizajes WHERE codigo = 'OA-CIE-B1');

--changeset practika:academic-009-only-four-mvp-subjects
INSERT INTO asignaturas (nombre_materia,activo)
SELECT d.nombre,1 FROM (SELECT 'Matemática' nombre UNION ALL SELECT 'Lenguaje' UNION ALL SELECT 'Historia' UNION ALL SELECT 'Ciencias') d
WHERE NOT EXISTS (SELECT 1 FROM asignaturas a WHERE a.nombre_materia=d.nombre);
UPDATE asignaturas SET activo=0;
UPDATE asignaturas a JOIN (SELECT id FROM (SELECT MIN(id_asignatura) id FROM asignaturas WHERE nombre_materia IN ('Lenguaje','Matemática','Historia','Ciencias') GROUP BY nombre_materia) canonical) c ON c.id=a.id_asignatura SET a.activo=1;
UPDATE cursos_portal c JOIN asignaturas a ON a.id_asignatura=c.id_asignatura SET c.activo=0 WHERE a.activo=0;

--changeset practika:academic-010-teacher-subject-specialty
CREATE TABLE docentes_asignaturas (
 run_profesor INT PRIMARY KEY,
 id_asignatura INT NOT NULL,
 CONSTRAINT fk_docente_asignatura FOREIGN KEY (id_asignatura) REFERENCES asignaturas(id_asignatura)
);

--changeset practika:academic-011-real-mvp-fixtures context:@dev
--validCheckSum: 9:e1e86ff9fa05dedc8258bbb13bbe0961
-- Inserts
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:4 SELECT COUNT(*) FROM asignaturas WHERE activo=1 AND ((id_asignatura=1 AND nombre_materia='Matemática') OR (id_asignatura=2 AND nombre_materia='Lenguaje') OR (id_asignatura=3 AND nombre_materia='Ciencias') OR (id_asignatura=5 AND nombre_materia='Historia'))
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM objetivo_aprendizajes WHERE id_aprendizaje BETWEEN 910001 AND 910008 OR codigo LIKE 'OA-MVP-%'
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM docentes_asignaturas WHERE run_profesor IN (12345679,12345671,12345682,12345683)
INSERT INTO objetivo_aprendizajes (id_aprendizaje,id_asignatura,codigo,descripcion_objetivo) VALUES
(910001,1,'OA-MVP-MAT-01','Contar, comparar, sumar y restar números hasta 20.'),
(910002,1,'OA-MVP-MAT-02','Reconocer figuras geométricas y describir posiciones.'),
(910003,2,'OA-MVP-LEN-01','Comprender un relato breve identificando personajes, lugar y secuencia.'),
(910004,2,'OA-MVP-LEN-02','Reconocer sonidos iniciales y sílabas, y escribir oraciones breves.'),
(910005,5,'OA-MVP-HIS-01','Ordenar acontecimientos cotidianos y reconocer días de la semana.'),
(910006,5,'OA-MVP-HIS-02','Reconocer normas de convivencia y acciones de cuidado en la comunidad.'),
(910007,3,'OA-MVP-CIE-01','Distinguir seres vivos y reconocer sus necesidades básicas.'),
(910008,3,'OA-MVP-CIE-02','Relacionar los sentidos con sus órganos y reconocer hábitos de cuidado.');
INSERT INTO docentes_asignaturas (run_profesor,id_asignatura) VALUES
(12345679,1),
(12345671,2),
(12345682,5),
(12345683,3);

--changeset practika:academic-012-teachers-both-primary-grades
ALTER TABLE docentes_asignaturas ADD COLUMN ambos_basicos BOOLEAN NOT NULL DEFAULT 0;

--changeset practika:academic-013-mvp-teachers-first-and-second context:@dev
UPDATE docentes_asignaturas SET ambos_basicos=1 WHERE run_profesor IN (12345679,12345671,12345682,12345683);

--changeset practika:academic-014-four-subject-image-objectives context:@dev
--validCheckSum: 9:e8594e26091763e1b8473e83473f3c4a
-- Datos
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Resolver operaciones y problemas de cálculo con números naturales.' WHERE id_aprendizaje=910001;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Reconocer figuras geométricas planas y sus propiedades.' WHERE id_aprendizaje=910002;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Identificar cuerpos geométricos y describir sus características.' WHERE id_aprendizaje=910009;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Organizar e interpretar datos mediante tablas y gráficos.' WHERE id_aprendizaje=910010;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Comprender textos, localizar información y realizar inferencias.' WHERE id_aprendizaje=910003;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Planificar y producir textos escritos claros para distintos propósitos.' WHERE id_aprendizaje=910004;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Leer y analizar obras literarias, sus personajes y recursos.' WHERE id_aprendizaje=910011;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Comunicar ideas oralmente y por escrito según el contexto.' WHERE id_aprendizaje=910012;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Observar muestras y usar instrumentos para investigar el mundo natural.' WHERE id_aprendizaje=910008;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Explicar propiedades y transformaciones de la materia.' WHERE id_aprendizaje=910013;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Explicar características, ciclos e interacciones de los seres vivos.' WHERE id_aprendizaje=910007;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Comprender fenómenos físicos mediante observación y modelos.' WHERE id_aprendizaje=910014;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Describir civilizaciones antiguas y sus aportes culturales.' WHERE id_aprendizaje=910005;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Reconocer la organización y legado de la antigua Roma.' WHERE id_aprendizaje=910015;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Analizar exploraciones y encuentros entre sociedades.' WHERE id_aprendizaje=910006;
UPDATE objetivo_aprendizajes SET descripcion_objetivo='Interpretar mapas y representar información espacial.' WHERE id_aprendizaje=910016;
INSERT INTO objetivo_aprendizajes (id_aprendizaje,id_asignatura,codigo,descripcion_objetivo) VALUES
(910009,1,'OA-MVP-MAT-03','Identificar cuerpos geométricos y describir sus características.'),
(910010,1,'OA-MVP-MAT-04','Organizar e interpretar datos mediante tablas y gráficos.'),
(910011,2,'OA-MVP-LEN-03','Leer y analizar obras literarias, sus personajes y recursos.'),
(910012,2,'OA-MVP-LEN-04','Comunicar ideas oralmente y por escrito según el contexto.'),
(910013,3,'OA-MVP-CIE-03','Explicar propiedades y transformaciones de la materia.'),
(910014,3,'OA-MVP-CIE-04','Comprender fenómenos físicos mediante observación y modelos.'),
(910015,5,'OA-MVP-HIS-03','Reconocer la organización y legado de la antigua Roma.'),
(910016,5,'OA-MVP-HIS-04','Interpretar mapas y representar información espacial.');

--changeset practika:academic-015-teacher-multiple-subjects
--validCheckSum: 9:f0564f16e12ec952ddbb5406792a6c1e
-- Columnas y relaciones
ALTER TABLE docentes_asignaturas DROP PRIMARY KEY, ADD PRIMARY KEY (run_profesor,id_asignatura);

--changeset practika:academic-016-reviewed-four-subjects-three-teachers context:@dev
--validCheckSum: 9:49dda4ab6c86c49953afbd2994afd420
-- Datos
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:4 SELECT COUNT(*) FROM asignaturas WHERE (id_asignatura=1 AND nombre_materia='Matemática') OR (id_asignatura=2 AND nombre_materia='Lenguaje') OR (id_asignatura=3 AND nombre_materia='Ciencias') OR (id_asignatura=5 AND nombre_materia='Historia')
--precondition-sql-check expectedResult:16 SELECT COUNT(*) FROM objetivo_aprendizajes WHERE id_aprendizaje BETWEEN 910001 AND 910016
UPDATE asignaturas SET activo=CASE WHEN id_asignatura IN (1,2,3,5) THEN 1 ELSE 0 END;
UPDATE cursos_portal SET activo=0 WHERE id_asignatura NOT IN (1,2,3,5);
DELETE FROM docentes_cursos_portal WHERE run_profesor=12345683;
DELETE FROM docentes_asignaturas WHERE run_profesor IN (12345679,12345671,12345682,12345683);
INSERT INTO docentes_asignaturas (run_profesor,id_asignatura,ambos_basicos) VALUES
(12345679,1,1),
(12345671,2,1),
(12345682,5,1),
(12345682,3,1);
UPDATE objetivo_aprendizajes SET id_asignatura=1,descripcion_objetivo='Resolver sumas, restas y problemas de cantidades hasta 20.' WHERE id_aprendizaje=910001;
UPDATE objetivo_aprendizajes SET id_asignatura=1,descripcion_objetivo='Reconocer figuras planas y describir sus lados, vértices y posiciones.' WHERE id_aprendizaje=910002;
UPDATE objetivo_aprendizajes SET id_asignatura=2,descripcion_objetivo='Localizar información, ordenar acciones y realizar inferencias a partir de relatos breves.' WHERE id_aprendizaje=910003;
UPDATE objetivo_aprendizajes SET id_asignatura=2,descripcion_objetivo='Escribir oraciones claras y revisar mayúsculas, puntuación y orden de las ideas.' WHERE id_aprendizaje=910004;
UPDATE objetivo_aprendizajes SET id_asignatura=5,descripcion_objetivo='Relacionar civilizaciones antiguas con sus ríos, actividades y aportes culturales.' WHERE id_aprendizaje=910005;
UPDATE objetivo_aprendizajes SET id_asignatura=5,descripcion_objetivo='Reconocer instrumentos de navegación y describir encuentros entre sociedades durante las exploraciones.' WHERE id_aprendizaje=910006;
UPDATE objetivo_aprendizajes SET id_asignatura=3,descripcion_objetivo='Reconocer seres vivos, sus necesidades y relaciones con el ambiente.' WHERE id_aprendizaje=910007;
UPDATE objetivo_aprendizajes SET id_asignatura=3,descripcion_objetivo='Reconocer las funciones del microscopio y describir observaciones de muestras.' WHERE id_aprendizaje=910008;
UPDATE objetivo_aprendizajes SET id_asignatura=1,descripcion_objetivo='Distinguir cuerpos geométricos y describir sus caras, aristas y vértices.' WHERE id_aprendizaje=910009;
UPDATE objetivo_aprendizajes SET id_asignatura=1,descripcion_objetivo='Organizar e interpretar cantidades en tablas y gráficos sencillos.' WHERE id_aprendizaje=910010;
UPDATE objetivo_aprendizajes SET id_asignatura=2,descripcion_objetivo='Reconocer personajes, ambientes y recursos de textos literarios breves.' WHERE id_aprendizaje=910011;
UPDATE objetivo_aprendizajes SET id_asignatura=2,descripcion_objetivo='Comunicar ideas con claridad y adaptar el mensaje a su propósito y destinatario.' WHERE id_aprendizaje=910012;
UPDATE objetivo_aprendizajes SET id_asignatura=3,descripcion_objetivo='Distinguir propiedades de materiales, mezclas y cambios de estado cotidianos.' WHERE id_aprendizaje=910013;
UPDATE objetivo_aprendizajes SET id_asignatura=3,descripcion_objetivo='Reconocer fuerzas, cambios en el movimiento y formas de energía del entorno.' WHERE id_aprendizaje=910014;
UPDATE objetivo_aprendizajes SET id_asignatura=5,descripcion_objetivo='Reconocer construcciones, espacios y legados culturales de la antigua Roma.' WHERE id_aprendizaje=910015;
UPDATE objetivo_aprendizajes SET id_asignatura=5,descripcion_objetivo='Interpretar mapas mediante orientación, símbolos, leyendas y escalas sencillas.' WHERE id_aprendizaje=910016;

--changeset practika:academic-017-primary-courses-with-stable-references context:@dev
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:4 SELECT COUNT(*) FROM asignaturas WHERE activo=1 AND id_asignatura IN (1,2,3,5)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM cursos_portal WHERE id_curso_portal IN (910101,910102,910103,910105,910201,910202,910203,910205) AND (id_periodo_academico IS NOT NULL OR id_seccion<>CASE WHEN id_curso_portal<910200 THEN 910001 ELSE 910002 END OR id_asignatura<>MOD(id_curso_portal,100))
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM cursos_portal WHERE id_seccion IN (910001,910002) AND id_periodo_academico IS NULL AND id_curso_portal<>910000+(id_seccion-910000)*100+id_asignatura
INSERT INTO cursos_portal (id_curso_portal,id_seccion,id_asignatura,nombre,activo)
SELECT 910000+g.grado*100+a.id_asignatura,910000+g.grado,a.id_asignatura,a.nombre_materia,1
FROM (SELECT 1 AS grado UNION ALL SELECT 2) g
CROSS JOIN asignaturas a
WHERE a.activo=1 AND a.id_asignatura IN (1,2,3,5)
ON DUPLICATE KEY UPDATE activo=1;

INSERT INTO docentes_cursos_portal (id_curso_portal,run_profesor)
SELECT c.id_curso_portal,d.run_profesor
FROM cursos_portal c JOIN docentes_asignaturas d ON d.id_asignatura=c.id_asignatura
WHERE c.id_curso_portal IN (910101,910102,910103,910105,910201,910202,910203,910205)
  AND d.ambos_basicos=1
ON DUPLICATE KEY UPDATE run_profesor=VALUES(run_profesor);
