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
