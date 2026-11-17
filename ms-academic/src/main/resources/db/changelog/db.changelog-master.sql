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
-- Data is copied explicitly from content during cutover, preserving identifiers.
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
-- Keep new development databases compatible with the observed legacy catalog (4=English, 5=History).
-- Existing subjects and references are never renumbered.
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
-- Shared IDs are a fixture contract between independent academic/content databases.
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
