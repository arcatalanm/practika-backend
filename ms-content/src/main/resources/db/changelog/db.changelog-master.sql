--liquibase formatted sql


--changeset practika:content-001-unidades
CREATE TABLE IF NOT EXISTS `unidades` (
  `id_unidad` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_unidades` PRIMARY KEY (`id_unidad`),
  `id_asignatura` INT NOT NULL,
  `id_objetivo` INT NOT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `descripcion` TEXT
);

--changeset practika:content-002-actividades
CREATE TABLE IF NOT EXISTS `actividades` (
  `id_actividad` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_actividades` PRIMARY KEY (`id_actividad`),
  `id_unidad` INT,
  `id_asignatura` INT,
  `id_curso` INT,
  `titulo` VARCHAR(150) NOT NULL,
  `estado_activo` BOOLEAN DEFAULT 1,
  `cantidad_intentos` INT DEFAULT 2
);

--changeset practika:content-003-pruebas
CREATE TABLE IF NOT EXISTS `pruebas` (
  `id_prueba` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_pruebas` PRIMARY KEY (`id_prueba`),
  `id_unidad` INT,
  `id_objetivo` INT,
  `id_curso` INT,
  `titulo` VARCHAR(150) NOT NULL,
  `fecha_aplicacion` DATETIME NOT NULL,
  `estado_activo` BOOLEAN DEFAULT 1,
  `cantidad_intentos` INT DEFAULT 2
);

--changeset practika:content-004-materiales
CREATE TABLE IF NOT EXISTS `materiales` (
  `id_material` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_materiales` PRIMARY KEY (`id_material`),
  `id_unidad` INT,
  `id_actividad` INT,
  `tipo_material` VARCHAR(20) NOT NULL,
  `contenido_url` TEXT NOT NULL
);

--changeset practika:content-005-preguntas
CREATE TABLE IF NOT EXISTS `preguntas` (
  `id_pregunta` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_preguntas` PRIMARY KEY (`id_pregunta`),
  `id_actividad` INT,
  `id_prueba` INT,
  `texto_pregunta` TEXT NOT NULL,
  `tipo_pregunta` VARCHAR(30) NOT NULL,
  `puntaje_maximo` DECIMAL(5,2) DEFAULT 1.00 NOT NULL
);

ALTER TABLE `preguntas` ADD CONSTRAINT `fk_preguntas_actividades` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`) ON DELETE CASCADE;

ALTER TABLE `preguntas` ADD CONSTRAINT `fk_preguntas_pruebas` FOREIGN KEY (`id_prueba`) REFERENCES `pruebas` (`id_prueba`) ON DELETE CASCADE;

--changeset practika:content-006-opciones
CREATE TABLE IF NOT EXISTS `opciones` (
  `id_opcion` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_opciones` PRIMARY KEY (`id_opcion`),
  `id_pregunta` INT NOT NULL,
  `texto_alternativa` TEXT NOT NULL,
  `es_correcta` BOOLEAN DEFAULT 0
);

ALTER TABLE `opciones` ADD CONSTRAINT `fk_opciones_preguntas` FOREIGN KEY (`id_pregunta`) REFERENCES `preguntas` (`id_pregunta`) ON DELETE CASCADE;

--changeset practika:content-007-unidades-cursos
CREATE TABLE IF NOT EXISTS `unidades_cursos` (
  `id_asignacion` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_unidades_cursos` PRIMARY KEY (`id_asignacion`),
  `id_unidad` INT NOT NULL,
  `id_curso` INT NOT NULL,
  `run_profesor` INT NOT NULL,
  `asignado_en` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE `unidades_cursos` ADD CONSTRAINT `uq_unidad_curso` UNIQUE (`id_unidad`, `id_curso`);

ALTER TABLE `unidades_cursos` ADD CONSTRAINT `fk_unidades_cursos_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;

--changeset practika:content-020-activity-unit-column
-- Columna legacy id_unidad ya incluida en CREATE TABLE.

--changeset practika:content-021-test-unit-column
-- Columna legacy id_unidad ya incluida en CREATE TABLE.

--changeset practika:content-022-material-unit-column
-- Columna legacy id_unidad ya incluida en CREATE TABLE.

--changeset practika:content-023-relax-legacy-content-columns
ALTER TABLE actividades MODIFY id_asignatura INT NULL, MODIFY id_curso INT NULL;

ALTER TABLE pruebas MODIFY id_objetivo INT NULL, MODIFY id_curso INT NULL;

ALTER TABLE materiales MODIFY id_actividad INT NULL;

--changeset practika:content-024-fk-activities-units
ALTER TABLE `actividades` ADD CONSTRAINT `fk_actividades_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;

--changeset practika:content-025-fk-tests-units
ALTER TABLE `pruebas` ADD CONSTRAINT `fk_pruebas_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;

--changeset practika:content-026-fk-materials-units
ALTER TABLE `materiales` ADD CONSTRAINT `fk_materiales_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;

--changeset practika:content-027-fk-materials-activities
ALTER TABLE `materiales` ADD CONSTRAINT `fk_materiales_actividades` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`) ON DELETE CASCADE;

--changeset practika:content-100-dev-data context:@dev
INSERT INTO unidades (id_unidad,id_asignatura,id_objetivo,titulo,descripcion) VALUES
            (1,1,1,'Fracciones en contexto','Representación, comparación y resolución de problemas con fracciones.'),
            (2,1,2,'Razones y porcentajes','Aplicaciones cotidianas de proporciones, razones y porcentajes.'),
            (3,2,3,'Leemos narraciones','Lectura y análisis de personajes, ambientes y conflictos.'),
            (4,2,4,'Escribimos para informar','Planificación y revisión de textos informativos.'),
            (5,3,5,'Cuerpo humano y salud','Relación entre sistemas, órganos y hábitos saludables.'),
            (6,3,6,'Materia y sus cambios','Observación de materiales y cambios de estado.');

INSERT INTO unidades_cursos (id_asignacion,id_unidad,id_curso,run_profesor,asignado_en) VALUES
            (1,1,1,12345679,'2026-10-01 09:00:00'),(2,2,1,12345679,'2026-10-02 09:00:00'),
            (3,3,2,12345671,'2026-10-01 09:00:00'),(4,4,2,12345671,'2026-10-02 09:00:00'),
            (5,5,3,12345682,'2026-10-03 09:00:00'),(6,6,4,12345683,'2026-10-03 09:00:00');

INSERT INTO actividades (id_actividad,id_unidad,id_asignatura,id_curso,titulo,estado_activo,cantidad_intentos) VALUES
            (1,1,NULL,NULL,'Representamos fracciones',1,2),(2,1,NULL,NULL,'Comparamos fracciones',1,2),
            (3,2,NULL,NULL,'Razones equivalentes',1,2),(4,2,NULL,NULL,'Porcentajes en compras',1,2),
            (5,3,NULL,NULL,'Personajes y ambiente',1,2),(6,3,NULL,NULL,'Secuencia narrativa',1,2),
            (7,4,NULL,NULL,'Ideas principales',1,2),(8,4,NULL,NULL,'Editamos un texto informativo',1,2),
            (9,5,NULL,NULL,'Sistemas del cuerpo',1,2),(10,5,NULL,NULL,'Hábitos saludables',1,2),
            (11,6,NULL,NULL,'Sólidos, líquidos y gases',1,2),(12,6,NULL,NULL,'Cambios de estado',1,2);

INSERT INTO pruebas (id_prueba,id_unidad,id_objetivo,id_curso,titulo,fecha_aplicacion,estado_activo,cantidad_intentos) VALUES
            (1,1,NULL,NULL,'Evaluación de fracciones','2026-11-02 09:00:00',1,2),(2,1,NULL,NULL,'Desafío de comparación','2026-11-03 09:00:00',1,2),
            (3,2,NULL,NULL,'Evaluación de razones','2026-11-04 09:00:00',1,2),(4,2,NULL,NULL,'Desafío de porcentajes','2026-11-05 09:00:00',1,2),
            (5,3,NULL,NULL,'Comprensión narrativa','2026-11-06 09:00:00',1,2),(6,3,NULL,NULL,'Lectura de cierre','2026-11-09 09:00:00',1,2),
            (7,4,NULL,NULL,'Plan de escritura','2026-11-10 09:00:00',1,2),(8,4,NULL,NULL,'Texto informativo final','2026-11-11 09:00:00',1,2),
            (9,5,NULL,NULL,'Sistemas y funciones','2026-11-12 09:00:00',1,2),(10,5,NULL,NULL,'Cuidado del cuerpo','2026-11-13 09:00:00',1,2),
            (11,6,NULL,NULL,'Estados de la materia','2026-11-16 09:00:00',1,2),(12,6,NULL,NULL,'Cambios observables','2026-11-17 09:00:00',1,2);

INSERT INTO materiales (id_material,id_unidad,id_actividad,tipo_material,contenido_url) VALUES
            (1,1,NULL,'PDF','https://example.org/practika/fracciones-guia.pdf'),(2,1,NULL,'VIDEO','https://example.org/practika/fracciones-video'),(3,1,NULL,'ENLACE','https://example.org/practika/fracciones-ejercicios'),
            (4,2,NULL,'PDF','https://example.org/practika/razones-guia.pdf'),(5,2,NULL,'VIDEO','https://example.org/practika/porcentajes-video'),(6,2,NULL,'ENLACE','https://example.org/practika/razones-ejercicios'),
            (7,3,NULL,'PDF','https://example.org/practika/narracion-guia.pdf'),(8,3,NULL,'VIDEO','https://example.org/practika/narracion-video'),(9,3,NULL,'ENLACE','https://example.org/practika/lectura'),
            (10,4,NULL,'PDF','https://example.org/practika/texto-informativo-guia.pdf'),(11,4,NULL,'VIDEO','https://example.org/practika/escritura-video'),(12,4,NULL,'ENLACE','https://example.org/practika/revision'),
            (13,5,NULL,'PDF','https://example.org/practika/sistemas-cuerpo-guia.pdf'),(14,5,NULL,'VIDEO','https://example.org/practika/cuerpo-video'),(15,5,NULL,'ENLACE','https://example.org/practika/salud'),
            (16,6,NULL,'PDF','https://example.org/practika/materia-guia.pdf'),(17,6,NULL,'VIDEO','https://example.org/practika/estados-video'),(18,6,NULL,'ENLACE','https://example.org/practika/cambios-materia');

INSERT INTO preguntas (id_pregunta,id_actividad,id_prueba,texto_pregunta,tipo_pregunta,puntaje_maximo)
            SELECT ((a.id_actividad - 1) * 4 + n.qn),a.id_actividad,NULL,CONCAT('Actividad ',a.id_actividad,': pregunta ',n.qn,' sobre el objetivo de la unidad.'),'SELECCION_MULTIPLE',1.00
            FROM actividades a CROSS JOIN (SELECT 1 qn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n;

INSERT INTO preguntas (id_pregunta,id_actividad,id_prueba,texto_pregunta,tipo_pregunta,puntaje_maximo)
            SELECT (48 + (p.id_prueba - 1) * 4 + n.qn),NULL,p.id_prueba,CONCAT('Prueba ',p.id_prueba,': pregunta ',n.qn,' de aplicación.'),'SELECCION_MULTIPLE',1.00
            FROM pruebas p CROSS JOIN (SELECT 1 qn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n;

INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta)
            SELECT ((p.id_pregunta - 1) * 4 + n.opn),p.id_pregunta,CONCAT('Alternativa ',n.opn,' para la pregunta ',p.id_pregunta),IF(n.opn = MOD(p.id_pregunta,4) + 1,1,0)
            FROM preguntas p CROSS JOIN (SELECT 1 opn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n;

--changeset practika:content-028-normalized-type-catalogs
CREATE TABLE `tipos_material` (
  `id_tipo_material` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(20) NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  `activo` BOOLEAN DEFAULT 1 NOT NULL,
  CONSTRAINT `pk_tipos_material` PRIMARY KEY (`id_tipo_material`),
  CONSTRAINT `uq_tipos_material_codigo` UNIQUE (`codigo`)
);

INSERT INTO `tipos_material` (`codigo`, `nombre`)
SELECT DISTINCT `tipo_material`, CASE `tipo_material`
  WHEN 'PDF' THEN 'Documento PDF' WHEN 'VIDEO' THEN 'Video' WHEN 'ENLACE' THEN 'Enlace'
  WHEN 'IMAGEN' THEN 'Imagen' WHEN 'DOCUMENTO' THEN 'Documento'
  ELSE `tipo_material` END
FROM `materiales`;
INSERT IGNORE INTO `tipos_material` (`codigo`, `nombre`) VALUES
('IMAGEN', 'Imagen'), ('DOCUMENTO', 'Documento');

CREATE TABLE `tipos_pregunta` (
  `id_tipo_pregunta` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(30) NOT NULL,
  `nombre` VARCHAR(60) NOT NULL,
  `activo` BOOLEAN DEFAULT 1 NOT NULL,
  CONSTRAINT `pk_tipos_pregunta` PRIMARY KEY (`id_tipo_pregunta`),
  CONSTRAINT `uq_tipos_pregunta_codigo` UNIQUE (`codigo`)
);

INSERT INTO `tipos_pregunta` (`codigo`, `nombre`)
SELECT DISTINCT `tipo_pregunta`, CASE `tipo_pregunta`
  WHEN 'SELECCION_MULTIPLE' THEN 'Selección múltiple'
  WHEN 'DESARROLLO' THEN 'Desarrollo'
  WHEN 'VERDADERO_FALSO' THEN 'Verdadero o falso'
  ELSE `tipo_pregunta` END
FROM `preguntas`;
INSERT IGNORE INTO `tipos_pregunta` (`codigo`, `nombre`) VALUES
('SELECCION_MULTIPLE', 'Selección múltiple'), ('DESARROLLO', 'Desarrollo'), ('VERDADERO_FALSO', 'Verdadero o falso');

ALTER TABLE `materiales` ADD COLUMN `id_tipo_material` INT NULL;
UPDATE `materiales` m JOIN `tipos_material` t ON t.`codigo` = m.`tipo_material`
SET m.`id_tipo_material` = t.`id_tipo_material`;
ALTER TABLE `materiales` MODIFY `id_tipo_material` INT NOT NULL;
ALTER TABLE `materiales` ADD CONSTRAINT `fk_materiales_tipos_material`
  FOREIGN KEY (`id_tipo_material`) REFERENCES `tipos_material` (`id_tipo_material`);
ALTER TABLE `materiales` DROP COLUMN `tipo_material`;

ALTER TABLE `preguntas` ADD COLUMN `id_tipo_pregunta` INT NULL;
UPDATE `preguntas` p JOIN `tipos_pregunta` t ON t.`codigo` = p.`tipo_pregunta`
SET p.`id_tipo_pregunta` = t.`id_tipo_pregunta`;
ALTER TABLE `preguntas` MODIFY `id_tipo_pregunta` INT NOT NULL;
ALTER TABLE `preguntas` ADD CONSTRAINT `fk_preguntas_tipos_pregunta`
  FOREIGN KEY (`id_tipo_pregunta`) REFERENCES `tipos_pregunta` (`id_tipo_pregunta`);
ALTER TABLE `preguntas` DROP COLUMN `tipo_pregunta`;

--changeset practika:content-029-portal-courses
CREATE TABLE IF NOT EXISTS `periodos_academicos` (
  `id_periodo_academico` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(20) NOT NULL,
  `nombre` VARCHAR(60) NOT NULL,
  `activo` BOOLEAN DEFAULT 1 NOT NULL,
  CONSTRAINT `pk_periodos_academicos` PRIMARY KEY (`id_periodo_academico`),
  CONSTRAINT `uq_periodos_academicos_codigo` UNIQUE (`codigo`)
);

INSERT IGNORE INTO `periodos_academicos` (`codigo`, `nombre`) VALUES
('2026-S1', 'Primer semestre 2026'), ('2026-S2', 'Segundo semestre 2026'),
('2027-S1', 'Primer semestre 2027'), ('2027-S2', 'Segundo semestre 2027');

CREATE TABLE IF NOT EXISTS `cursos_portal` (
  `id_curso_portal` INT AUTO_INCREMENT NOT NULL,
  `id_seccion` INT NOT NULL,
  `id_asignatura` INT NOT NULL,
  `id_periodo_academico` INT NOT NULL,
  `nombre` VARCHAR(120) NOT NULL,
  `descripcion` TEXT,
  `activo` BOOLEAN DEFAULT 1 NOT NULL,
  CONSTRAINT `pk_cursos_portal` PRIMARY KEY (`id_curso_portal`),
  CONSTRAINT `uq_curso_portal_seccion_asignatura_periodo` UNIQUE (`id_seccion`, `id_asignatura`, `id_periodo_academico`),
  CONSTRAINT `fk_cursos_portal_periodos` FOREIGN KEY (`id_periodo_academico`)
    REFERENCES `periodos_academicos` (`id_periodo_academico`)
);

INSERT IGNORE INTO `cursos_portal` (`id_seccion`, `id_asignatura`, `id_periodo_academico`, `nombre`, `descripcion`, `activo`)
SELECT uc.`id_curso`, u.`id_asignatura`, p.`id_periodo_academico`,
       CONCAT('Asignatura ', u.`id_asignatura`, ' · Sección ', uc.`id_curso`), NULL, 1
FROM `unidades_cursos` uc
JOIN `unidades` u ON u.`id_unidad` = uc.`id_unidad`
JOIN `periodos_academicos` p ON p.`codigo` = '2026-S2'
GROUP BY uc.`id_curso`, u.`id_asignatura`, p.`id_periodo_academico`;

CREATE TABLE IF NOT EXISTS `docentes_cursos_portal` (
  `id_docente_curso` INT AUTO_INCREMENT NOT NULL,
  `id_curso_portal` INT NOT NULL,
  `run_profesor` INT NOT NULL,
  CONSTRAINT `pk_docentes_cursos_portal` PRIMARY KEY (`id_docente_curso`),
  CONSTRAINT `uq_docente_curso_portal` UNIQUE (`id_curso_portal`, `run_profesor`),
  CONSTRAINT `fk_docentes_cursos_portal_curso` FOREIGN KEY (`id_curso_portal`)
    REFERENCES `cursos_portal` (`id_curso_portal`)
);

INSERT IGNORE INTO `docentes_cursos_portal` (`id_curso_portal`, `run_profesor`)
SELECT DISTINCT cp.`id_curso_portal`, uc.`run_profesor`
FROM `unidades_cursos` uc
JOIN `unidades` u ON u.`id_unidad` = uc.`id_unidad`
JOIN `cursos_portal` cp ON cp.`id_seccion` = uc.`id_curso` AND cp.`id_asignatura` = u.`id_asignatura`;

SET @add_curso_portal_column = (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `unidades_cursos` ADD COLUMN `id_curso_portal` INT NULL',
    'SELECT 1')
  FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos' AND `COLUMN_NAME` = 'id_curso_portal'
);
PREPARE add_curso_portal_column FROM @add_curso_portal_column;
EXECUTE add_curso_portal_column;
DEALLOCATE PREPARE add_curso_portal_column;
UPDATE `unidades_cursos` uc
JOIN `unidades` u ON u.`id_unidad` = uc.`id_unidad`
JOIN `cursos_portal` cp ON cp.`id_seccion` = uc.`id_curso` AND cp.`id_asignatura` = u.`id_asignatura`
SET uc.`id_curso_portal` = cp.`id_curso_portal`;
ALTER TABLE `unidades_cursos` MODIFY `id_curso_portal` INT NOT NULL;
SET @drop_unit_fk = (
  SELECT IF(COUNT(*) > 0,
    'ALTER TABLE `unidades_cursos` DROP FOREIGN KEY `fk_unidades_cursos_unidad`',
    'SELECT 1')
  FROM `information_schema`.`TABLE_CONSTRAINTS`
  WHERE `CONSTRAINT_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos'
    AND `CONSTRAINT_NAME` = 'fk_unidades_cursos_unidad' AND `CONSTRAINT_TYPE` = 'FOREIGN KEY'
);
PREPARE drop_unit_fk FROM @drop_unit_fk;
EXECUTE drop_unit_fk;
DEALLOCATE PREPARE drop_unit_fk;

SET @drop_legacy_assignment_index = (
  SELECT IF(COUNT(*) > 0,
    'ALTER TABLE `unidades_cursos` DROP INDEX `uq_unidad_curso`',
    'SELECT 1')
  FROM `information_schema`.`STATISTICS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos' AND `INDEX_NAME` = 'uq_unidad_curso'
);
PREPARE drop_legacy_assignment_index FROM @drop_legacy_assignment_index;
EXECUTE drop_legacy_assignment_index;
DEALLOCATE PREPARE drop_legacy_assignment_index;

SET @drop_legacy_course_column = (
  SELECT IF(COUNT(*) > 0,
    'ALTER TABLE `unidades_cursos` DROP COLUMN `id_curso`',
    'SELECT 1')
  FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos' AND `COLUMN_NAME` = 'id_curso'
);
PREPARE drop_legacy_course_column FROM @drop_legacy_course_column;
EXECUTE drop_legacy_course_column;
DEALLOCATE PREPARE drop_legacy_course_column;

SET @add_portal_unique_index = (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `unidades_cursos` ADD CONSTRAINT `uq_unidad_curso_portal` UNIQUE (`id_unidad`, `id_curso_portal`)',
    'SELECT 1')
  FROM `information_schema`.`STATISTICS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos' AND `INDEX_NAME` = 'uq_unidad_curso_portal'
);
PREPARE add_portal_unique_index FROM @add_portal_unique_index;
EXECUTE add_portal_unique_index;
DEALLOCATE PREPARE add_portal_unique_index;

SET @add_unit_fk = (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `unidades_cursos` ADD CONSTRAINT `fk_unidades_cursos_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE',
    'SELECT 1')
  FROM `information_schema`.`TABLE_CONSTRAINTS`
  WHERE `CONSTRAINT_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos'
    AND `CONSTRAINT_NAME` = 'fk_unidades_cursos_unidad' AND `CONSTRAINT_TYPE` = 'FOREIGN KEY'
);
PREPARE add_unit_fk FROM @add_unit_fk;
EXECUTE add_unit_fk;
DEALLOCATE PREPARE add_unit_fk;

SET @add_portal_course_fk = (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `unidades_cursos` ADD CONSTRAINT `fk_unidades_cursos_curso_portal` FOREIGN KEY (`id_curso_portal`) REFERENCES `cursos_portal` (`id_curso_portal`)',
    'SELECT 1')
  FROM `information_schema`.`TABLE_CONSTRAINTS`
  WHERE `CONSTRAINT_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'unidades_cursos' AND `CONSTRAINT_NAME` = 'fk_unidades_cursos_curso_portal'
);
PREPARE add_portal_course_fk FROM @add_portal_course_fk;
EXECUTE add_portal_course_fk;
DEALLOCATE PREPARE add_portal_course_fk;

--changeset practika:content-030-material-active
ALTER TABLE `materiales` ADD COLUMN `activo` BOOLEAN NOT NULL DEFAULT 1;

--changeset practika:content-031-remove-legacy-activity-links
ALTER TABLE `actividades` DROP COLUMN `id_asignatura`, DROP COLUMN `id_curso`;
ALTER TABLE `pruebas` DROP COLUMN `id_objetivo`, DROP COLUMN `id_curso`;

--changeset practika:content-032-reading-material
ALTER TABLE `materiales`
  ADD COLUMN `titulo` VARCHAR(200) NULL,
  ADD COLUMN `contenido_texto` LONGTEXT NULL,
  MODIFY COLUMN `contenido_url` TEXT NULL;
INSERT IGNORE INTO `tipos_material` (`codigo`, `nombre`, `activo`) VALUES
('TEXTO', 'Texto de lectura', 1), ('PDF', 'Documento PDF', 1),
('VIDEO', 'Video', 1), ('ENLACE', 'Enlace', 1);

--changeset practika:content-033-question-materials
ALTER TABLE `materiales` ADD COLUMN `id_pregunta` INT NULL,
  ADD CONSTRAINT `fk_materiales_preguntas` FOREIGN KEY (`id_pregunta`)
  REFERENCES `preguntas` (`id_pregunta`) ON DELETE CASCADE;
INSERT IGNORE INTO `tipos_material` (`codigo`, `nombre`, `activo`) VALUES
('GIF', 'Imagen animada', 1), ('AUDIO', 'Audio', 1);
INSERT IGNORE INTO `tipos_pregunta` (`codigo`, `nombre`, `activo`) VALUES
('SELECCION_UNICA', 'Una alternativa', 1);

--changeset practika:content-036-retire-unit-materials
-- Archive the retired unit-only resources; retain all question and activity resources.
CREATE TABLE `materiales_unidad_archivados` AS SELECT * FROM `materiales`
WHERE `id_unidad` IS NOT NULL AND `id_pregunta` IS NULL AND `id_actividad` IS NULL;
DELETE FROM `materiales` WHERE `id_unidad` IS NOT NULL AND `id_pregunta` IS NULL AND `id_actividad` IS NULL;
ALTER TABLE `materiales` DROP FOREIGN KEY `fk_materiales_unidades`, DROP COLUMN `id_unidad`;

--changeset practika:content-038-uploaded-question-resources
CREATE TABLE `archivos_recursos` (
  `id` VARCHAR(36) PRIMARY KEY,
  `id_pregunta` INT NOT NULL,
  `nombre` VARCHAR(200) NOT NULL,
  `tipo_contenido` VARCHAR(80) NOT NULL,
  `contenido` LONGBLOB NOT NULL,
  CONSTRAINT `fk_archivos_recursos_pregunta` FOREIGN KEY (`id_pregunta`) REFERENCES `preguntas` (`id_pregunta`) ON DELETE CASCADE
);

--changeset practika:content-039-local-invariants
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM actividades WHERE id_unidad IS NULL OR cantidad_intentos IS NULL OR cantidad_intentos NOT BETWEEN 1 AND 20
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pruebas WHERE id_unidad IS NULL OR cantidad_intentos IS NULL OR cantidad_intentos NOT BETWEEN 1 AND 20
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM preguntas WHERE (id_actividad IS NULL) = (id_prueba IS NULL) OR puntaje_maximo <= 0
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM materiales WHERE (id_actividad IS NULL) = (id_pregunta IS NULL)
ALTER TABLE `actividades` DROP FOREIGN KEY `fk_actividades_unidades`,
  MODIFY `id_unidad` INT NOT NULL, MODIFY `cantidad_intentos` INT NOT NULL DEFAULT 1,
  ADD CONSTRAINT `chk_actividad_intentos` CHECK (`cantidad_intentos` BETWEEN 1 AND 20),
  ADD CONSTRAINT `fk_actividades_unidades_requerida` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;
ALTER TABLE `pruebas` DROP FOREIGN KEY `fk_pruebas_unidades`,
  MODIFY `id_unidad` INT NOT NULL, MODIFY `cantidad_intentos` INT NOT NULL DEFAULT 1,
  ADD CONSTRAINT `chk_prueba_intentos` CHECK (`cantidad_intentos` BETWEEN 1 AND 20),
  ADD CONSTRAINT `fk_pruebas_unidades_requerida` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE;
ALTER TABLE `preguntas` ADD CONSTRAINT `chk_pregunta_destino` CHECK ((`id_actividad` IS NOT NULL) <> (`id_prueba` IS NOT NULL)),
  ADD CONSTRAINT `chk_pregunta_puntaje` CHECK (`puntaje_maximo` > 0);
ALTER TABLE `materiales` ADD CONSTRAINT `chk_material_destino` CHECK ((`id_actividad` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-040-published-course-evaluations
CREATE TABLE `evaluaciones_asignadas` (
  `id_evaluacion_asignada` INT AUTO_INCREMENT PRIMARY KEY,
  `id_asignacion` INT NOT NULL,
  `id_actividad` INT NULL,
  `id_prueba` INT NULL,
  `version` INT NOT NULL,
  `publicada_en` DATETIME(6) NOT NULL,
  `run_publicador` INT NOT NULL,
  `activa` BOOLEAN NOT NULL DEFAULT 1,
  `huella_origen` VARCHAR(64) NOT NULL,
  `contenido_snapshot` LONGTEXT NOT NULL,
  CONSTRAINT `fk_evaluaciones_asignacion` FOREIGN KEY (`id_asignacion`) REFERENCES `unidades_cursos` (`id_asignacion`),
  CONSTRAINT `fk_evaluaciones_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`),
  CONSTRAINT `fk_evaluaciones_prueba` FOREIGN KEY (`id_prueba`) REFERENCES `pruebas` (`id_prueba`),
  CONSTRAINT `uq_evaluacion_actividad_version` UNIQUE (`id_asignacion`,`id_actividad`,`version`),
  CONSTRAINT `uq_evaluacion_prueba_version` UNIQUE (`id_asignacion`,`id_prueba`,`version`),
  CONSTRAINT `chk_evaluacion_destino` CHECK ((`id_actividad` IS NOT NULL) <> (`id_prueba` IS NOT NULL)),
  CONSTRAINT `chk_evaluacion_version` CHECK (`version` >= 1)
);
CREATE TABLE `archivos_evaluacion` (
  `id` VARCHAR(36) PRIMARY KEY,
  `id_evaluacion_asignada` INT NOT NULL,
  `nombre` VARCHAR(200) NOT NULL,
  `tipo_contenido` VARCHAR(80) NOT NULL,
  `contenido` LONGBLOB NOT NULL,
  CONSTRAINT `fk_archivos_evaluacion_publicacion` FOREIGN KEY (`id_evaluacion_asignada`)
    REFERENCES `evaluaciones_asignadas` (`id_evaluacion_asignada`)
);

--changeset practika:content-041-initial-publication-marker
ALTER TABLE `unidades_cursos` ADD COLUMN `publicacion_inicializada` BOOLEAN NOT NULL DEFAULT 0;

--changeset practika:content-042-activity-resource-files
ALTER TABLE `archivos_recursos` MODIFY COLUMN `id_pregunta` INT NULL;
ALTER TABLE `archivos_recursos` ADD COLUMN `id_actividad` INT NULL;
ALTER TABLE `archivos_recursos` ADD CONSTRAINT `fk_archivos_recursos_actividad`
  FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`) ON DELETE CASCADE;
ALTER TABLE `archivos_recursos` ADD CONSTRAINT `chk_archivo_recurso_destino`
  CHECK ((`id_pregunta` IS NOT NULL) <> (`id_actividad` IS NOT NULL));

--changeset practika:content-043-academic-course-reference
-- Courses are owned by academic. Keep the old tables as a cutover backup;
-- they must no longer constrain new assignments to academic-owned courses.
ALTER TABLE `unidades_cursos` DROP FOREIGN KEY `fk_unidades_cursos_curso_portal`;

--changeset practika:content-044-unified-evaluation-table
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:1 SELECT IF((SELECT COALESCE(MAX(id_actividad),0) FROM actividades)+(SELECT COALESCE(MAX(id_prueba),0) FROM pruebas)<2147483647,1,0)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM actividades WHERE id_actividad<=0
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pruebas WHERE id_prueba<=0
CREATE TABLE IF NOT EXISTS `evaluaciones` (
  `id_evaluacion` INT AUTO_INCREMENT PRIMARY KEY,
  `tipo` VARCHAR(16) NOT NULL,
  `id_legacy` INT NULL,
  `id_unidad` INT NOT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `estado_activo` BOOLEAN DEFAULT 1,
  `cantidad_intentos` INT NOT NULL DEFAULT 1,
  `fecha_aplicacion` DATETIME NULL,
  CONSTRAINT `uq_evaluacion_legacy` UNIQUE (`tipo`,`id_legacy`),
  CONSTRAINT `chk_evaluacion_tipo_fecha` CHECK ((`tipo`='ACTIVIDAD' AND `fecha_aplicacion` IS NULL) OR (`tipo`='PRUEBA' AND `fecha_aplicacion` IS NOT NULL)),
  CONSTRAINT `chk_evaluacion_intentos` CHECK (`cantidad_intentos` BETWEEN 1 AND 20),
  CONSTRAINT `fk_evaluacion_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE
);
INSERT INTO `evaluaciones` (`id_evaluacion`,`tipo`,`id_legacy`,`id_unidad`,`titulo`,`estado_activo`,`cantidad_intentos`)
SELECT a.`id_actividad`,'ACTIVIDAD',a.`id_actividad`,a.`id_unidad`,a.`titulo`,a.`estado_activo`,a.`cantidad_intentos`
FROM `actividades` a WHERE NOT EXISTS (SELECT 1 FROM `evaluaciones` e WHERE e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=a.`id_actividad`);
INSERT INTO `evaluaciones` (`id_evaluacion`,`tipo`,`id_legacy`,`id_unidad`,`titulo`,`estado_activo`,`cantidad_intentos`,`fecha_aplicacion`)
SELECT (SELECT COALESCE(MAX(`id_actividad`),0) FROM `actividades`)+p.`id_prueba`,'PRUEBA',p.`id_prueba`,p.`id_unidad`,p.`titulo`,p.`estado_activo`,p.`cantidad_intentos`,p.`fecha_aplicacion`
FROM `pruebas` p WHERE NOT EXISTS (SELECT 1 FROM `evaluaciones` e WHERE e.`tipo`='PRUEBA' AND e.`id_legacy`=p.`id_prueba`);

--changeset practika:content-045-verify-evaluation-copy
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT (SELECT COUNT(*) FROM evaluaciones)-(SELECT COUNT(*) FROM actividades)-(SELECT COUNT(*) FROM pruebas)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM actividades a LEFT JOIN evaluaciones e ON e.tipo='ACTIVIDAD' AND e.id_legacy=a.id_actividad WHERE e.id_evaluacion IS NULL OR NOT(e.id_unidad<=>a.id_unidad AND e.titulo<=>a.titulo AND e.estado_activo<=>a.estado_activo AND e.cantidad_intentos<=>a.cantidad_intentos AND e.fecha_aplicacion IS NULL)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pruebas p LEFT JOIN evaluaciones e ON e.tipo='PRUEBA' AND e.id_legacy=p.id_prueba WHERE e.id_evaluacion IS NULL OR NOT(e.id_unidad<=>p.id_unidad AND e.titulo<=>p.titulo AND e.estado_activo<=>p.estado_activo AND e.cantidad_intentos<=>p.cantidad_intentos AND e.fecha_aplicacion<=>p.fecha_aplicacion)
SELECT 1;

--changeset practika:content-046-preguntas-evaluation-column
ALTER TABLE `preguntas` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-047-preguntas-evaluation-copy
UPDATE `preguntas` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;
UPDATE `preguntas` t JOIN `evaluaciones` e ON e.`tipo`='PRUEBA' AND e.`id_legacy`=t.`id_prueba` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_prueba` IS NOT NULL;

--changeset practika:content-048-preguntas-evaluation-contract
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM preguntas WHERE id_evaluacion IS NULL
ALTER TABLE `preguntas`
  DROP FOREIGN KEY `fk_preguntas_actividades`,
  DROP FOREIGN KEY `fk_preguntas_pruebas`,
  DROP CHECK `chk_pregunta_destino`,
  DROP COLUMN `id_actividad`,
  DROP COLUMN `id_prueba`,
  MODIFY COLUMN `id_evaluacion` INT NOT NULL,
  ADD CONSTRAINT `fk_pregunta_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE;

--changeset practika:content-049-materiales-evaluation-column
ALTER TABLE `materiales` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-050-materiales-evaluation-copy
UPDATE `materiales` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;

--changeset practika:content-051-materiales-evaluation-contract
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM materiales WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `materiales`
  DROP FOREIGN KEY `fk_materiales_actividades`,
  DROP CHECK `chk_material_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_material_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_materiales_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-052-archivos_recursos-evaluation-column
ALTER TABLE `archivos_recursos` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-053-archivos_recursos-evaluation-copy
UPDATE `archivos_recursos` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;

--changeset practika:content-054-archivos_recursos-evaluation-contract
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM archivos_recursos WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `archivos_recursos`
  DROP FOREIGN KEY `fk_archivos_recursos_actividad`,
  DROP CHECK `chk_archivo_recurso_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_archivo_recurso_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_archivos_recursos_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-055-evaluaciones_asignadas-evaluation-column
ALTER TABLE `evaluaciones_asignadas` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-056-evaluaciones_asignadas-evaluation-copy
UPDATE `evaluaciones_asignadas` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;
UPDATE `evaluaciones_asignadas` t JOIN `evaluaciones` e ON e.`tipo`='PRUEBA' AND e.`id_legacy`=t.`id_prueba` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_prueba` IS NOT NULL;

--changeset practika:content-057-evaluaciones_asignadas-evaluation-contract
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM evaluaciones_asignadas WHERE id_evaluacion IS NULL
ALTER TABLE `evaluaciones_asignadas`
  ADD CONSTRAINT `uq_publicacion_evaluacion_version` UNIQUE (`id_asignacion`,`id_evaluacion`,`version`),
  DROP FOREIGN KEY `fk_evaluaciones_actividad`,
  DROP FOREIGN KEY `fk_evaluaciones_prueba`,
  DROP CHECK `chk_evaluacion_destino`,
  DROP INDEX `uq_evaluacion_actividad_version`,
  DROP INDEX `uq_evaluacion_prueba_version`,
  DROP COLUMN `id_actividad`,
  DROP COLUMN `id_prueba`,
  MODIFY COLUMN `id_evaluacion` INT NOT NULL,
  ADD CONSTRAINT `fk_publicacion_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`);

-- Legacy actividades/pruebas tables remain as cutover archives. Application writes use evaluaciones only.

--changeset practika:content-058-detach-activity-archive
ALTER TABLE `actividades` DROP FOREIGN KEY `fk_actividades_unidades_requerida`;

--changeset practika:content-059-detach-test-archive
ALTER TABLE `pruebas` DROP FOREIGN KEY `fk_pruebas_unidades_requerida`;

--changeset practika:content-060-unit-images
CREATE TABLE IF NOT EXISTS `unidad_imagenes` (
  `id_unidad` INT NOT NULL,
  `contenido` MEDIUMBLOB NOT NULL,
  `tipo_contenido` VARCHAR(50) NOT NULL,
  CONSTRAINT `pk_unidad_imagenes` PRIMARY KEY (`id_unidad`),
  CONSTRAINT `fk_unidad_imagenes_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON DELETE CASCADE
);
ALTER TABLE `unidades` ADD COLUMN `img_unidad` VARCHAR(255) NULL;

--changeset practika:content-061-real-first-grade-fixtures context:@dev
-- Add curated material without deleting old publications, resources or grading history.
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM unidades WHERE id_unidad BETWEEN 910001 AND 910008
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM evaluaciones WHERE id_evaluacion BETWEEN 920001 AND 920024
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM preguntas WHERE id_pregunta BETWEEN 930001 AND 930096
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM opciones WHERE id_opcion BETWEEN 940001 AND 940400
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM materiales WHERE id_material BETWEEN 950001 AND 950096
--precondition-sql-check expectedResult:4 SELECT COUNT(*) FROM tipos_pregunta WHERE codigo IN ('SELECCION_UNICA','SELECCION_MULTIPLE','VERDADERO_FALSO','DESARROLLO')
--precondition-sql-check expectedResult:1 SELECT COUNT(*) FROM tipos_material WHERE codigo='TEXTO'
-- Retire only original example evaluations; preserve their archived versions and answers.
UPDATE evaluaciones SET estado_activo=0 WHERE (tipo='ACTIVIDAD' AND id_legacy BETWEEN 1 AND 13) OR (tipo='PRUEBA' AND id_legacy BETWEEN 1 AND 12);
UPDATE evaluaciones_asignadas p JOIN evaluaciones e ON e.id_evaluacion=p.id_evaluacion SET p.activa=0
WHERE (e.tipo='ACTIVIDAD' AND e.id_legacy BETWEEN 1 AND 13) OR (e.tipo='PRUEBA' AND e.id_legacy BETWEEN 1 AND 12);
INSERT INTO unidades (id_unidad,id_asignatura,id_objetivo,titulo,descripcion) VALUES
(910001,1,910001,'Números y operaciones hasta el 20','Cuenta objetos y resuelve problemas sencillos de agregar y quitar. Usa dibujos o fichas para explicar tus respuestas.'),
(910002,1,910002,'Figuras y posiciones a nuestro alrededor','Reconoce círculos, triángulos, cuadrados y rectángulos. Describe posiciones usando arriba, abajo, dentro y fuera.'),
(910003,2,910003,'Leemos el cuento de Luna y la semilla','Lee un cuento breve, reconoce sus personajes y ordena lo que ocurre al inicio, durante y al final.'),
(910004,2,910004,'Jugamos con sonidos, sílabas y oraciones','Escucha sonidos iniciales, separa palabras en sílabas y escribe oraciones que comuniquen una idea.'),
(910005,4,910005,'El tiempo en nuestra vida cotidiana','Ordena rutinas usando antes y después. Reconoce los días de la semana y cambios que ocurren con el paso del tiempo.'),
(910006,4,910006,'Convivimos y cuidamos nuestra comunidad','Reconoce acuerdos que ayudan a convivir, respeta a otras personas y propone acciones para cuidar espacios compartidos.'),
(910007,3,910007,'Seres vivos y sus necesidades','Distingue seres vivos de objetos sin vida y reconoce lo que plantas y animales necesitan para vivir.'),
(910008,3,910008,'Nuestros sentidos y el cuidado del cuerpo','Relaciona vista, audición, olfato, gusto y tacto con los órganos correspondientes. Reconoce hábitos saludables y cuidados cotidianos.');
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920001,'ACTIVIDAD',910001,'Exploramos: Números y operaciones hasta el 20',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930001,920001,'En un canasto hay 8 manzanas. Agregamos 3. ¿Cuántas manzanas hay ahora?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940001,930001,'11',1),
(940002,930001,'5',0),
(940003,930001,'8',0),
(940004,930001,'13',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950001,930001,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930002,920001,'¿Qué número viene inmediatamente después del 14?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940005,930002,'13',0),
(940006,930002,'16',0),
(940007,930002,'12',0),
(940008,930002,'15',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950002,930002,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930003,920001,'Marca todos los números mayores que 10.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940009,930003,'7',0),
(940010,930003,'10',0),
(940011,930003,'12',1),
(940012,930003,'18',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950003,930003,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930004,920001,'Si tengo 6 semillas y recibo 2 más, ahora tengo 8 semillas.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940013,930004,'Falso',0),
(940014,930004,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950004,930004,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920002,'ACTIVIDAD',910001,'Aplicamos y explicamos: Números y operaciones hasta el 20',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930005,920002,'Había 15 flores. Cortamos 4 para un florero. ¿Cuántas quedan?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940015,930005,'11',1),
(940016,930005,'19',0),
(940017,930005,'9',0),
(940018,930005,'4',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950005,930005,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930006,920002,'El número 9 es mayor que el número 12.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940019,930006,'Falso',1),
(940020,930006,'Verdadero',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950006,930006,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930007,920002,'Dibuja o describe cómo resolverías 7 + 5. Escribe el resultado.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950007,930007,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930008,920002,'Inventa un problema donde tengas 10 objetos y regales 3. ¿Cuántos te quedan?',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950008,930008,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920003,'PRUEBA',910001,'Prueba de cierre: Números y operaciones hasta el 20',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930009,920003,'Tomás tiene 9 lápices y encuentra 4 más. ¿Cuántos tiene en total?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940021,930009,'13',1),
(940022,930009,'5',0),
(940023,930009,'14',0),
(940024,930009,'9',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950009,930009,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930010,920003,'Marca las operaciones cuyo resultado es 10.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940025,930010,'12 - 2',1),
(940026,930010,'5 + 4',0),
(940027,930010,'10 - 1',0),
(940028,930010,'6 + 4',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950010,930010,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930011,920003,'Si a 18 le quitamos 3, quedan 15.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940029,930011,'Verdadero',1),
(940030,930011,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950011,930011,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930012,920003,'Lucía tenía 16 semillas y plantó 6. ¿Cuántas le quedan? Explica cómo lo sabes.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950012,930012,id_tipo_material,'Lee y observa: Números y operaciones hasta el 20','En el huerto de la escuela hay canastos, semillas y flores. Lee con atención cuántos objetos hay al comienzo y qué cambia en cada problema. Puedes dibujar los objetos para contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920004,'ACTIVIDAD',910002,'Exploramos: Figuras y posiciones a nuestro alrededor',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930013,920004,'¿Qué figura tiene exactamente tres lados?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940031,930013,'Cuadrado',0),
(940032,930013,'Círculo',0),
(940033,930013,'Rectángulo',0),
(940034,930013,'Triángulo',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950013,930013,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930014,920004,'¿Cuál de estas figuras no tiene lados rectos?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940035,930014,'Cuadrado',0),
(940036,930014,'Rectángulo',0),
(940037,930014,'Círculo',1),
(940038,930014,'Triángulo',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950014,930014,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930015,920004,'Marca las figuras que tienen cuatro lados.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940039,930015,'Triángulo',0),
(940040,930015,'Cuadrado',1),
(940041,930015,'Rectángulo',1),
(940042,930015,'Círculo',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950015,930015,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930016,920004,'Un cuadrado tiene cuatro lados del mismo largo.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940043,930016,'Verdadero',1),
(940044,930016,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950016,930016,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920005,'ACTIVIDAD',910002,'Aplicamos y explicamos: Figuras y posiciones a nuestro alrededor',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930017,920005,'La pelota está dentro de una caja. ¿Dónde está la pelota?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940045,930017,'Sobre la caja',0),
(940046,930017,'Debajo de la caja',0),
(940047,930017,'Fuera de la caja',0),
(940048,930017,'En el interior de la caja',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950017,930017,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930018,920005,'Un triángulo tiene cuatro esquinas.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940049,930018,'Verdadero',0),
(940050,930018,'Falso',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950018,930018,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930019,920005,'Nombra un objeto de tu casa que tenga forma de círculo y otro con forma de rectángulo.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950019,930019,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930020,920005,'Describe dónde está tu mochila usando arriba, abajo, dentro o fuera.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950020,930020,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920006,'PRUEBA',910002,'Prueba de cierre: Figuras y posiciones a nuestro alrededor',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930021,920006,'Una figura tiene cuatro lados iguales y cuatro esquinas rectas. ¿Qué figura es?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940051,930021,'Círculo',0),
(940052,930021,'Triángulo',0),
(940053,930021,'Óvalo',0),
(940054,930021,'Cuadrado',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950021,930021,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930022,920006,'Marca los objetos que suelen tener forma de rectángulo.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940055,930022,'Una moneda',0),
(940056,930022,'Una pelota',0),
(940057,930022,'Una puerta',1),
(940058,930022,'La tapa de un cuaderno',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950022,930022,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930023,920006,'Si guardo un lápiz en un estuche cerrado, el lápiz está fuera del estuche.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940059,930023,'Falso',1),
(940060,930023,'Verdadero',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950023,930023,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930024,920006,'Explica una diferencia entre un triángulo y un cuadrado.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950024,930024,id_tipo_material,'Lee y observa: Figuras y posiciones a nuestro alrededor','Mira tu sala y piensa en sus objetos: ventanas, puertas, relojes y cuadernos. Puedes dibujar las figuras de cada pregunta para observar sus lados y esquinas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920007,'ACTIVIDAD',910003,'Exploramos: Leemos el cuento de Luna y la semilla',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930025,920007,'¿Quién encontró la semilla?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940061,930025,'La profesora',0),
(940062,930025,'La abuela',0),
(940063,930025,'Luna',1),
(940064,930025,'Tomás',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950025,930025,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930026,920007,'¿Dónde encontró Luna la semilla?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940065,930026,'En el bosque',0),
(940066,930026,'En el patio de la escuela',1),
(940067,930026,'En la cocina',0),
(940068,930026,'En una plaza',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950026,930026,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930027,920007,'Marca a los personajes que aparecen en el cuento.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940069,930027,'Luna',1),
(940070,930027,'Tomás',1),
(940071,930027,'Pedro',0),
(940072,930027,'María',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950027,930027,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930028,920007,'Luna regó la semilla cada mañana.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940073,930028,'Falso',0),
(940074,930028,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950028,930028,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920008,'ACTIVIDAD',910003,'Aplicamos y explicamos: Leemos el cuento de Luna y la semilla',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930029,920008,'¿Qué apareció después de varios días?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940075,930029,'Un juguete',0),
(940076,930029,'Una mariposa',0),
(940077,930029,'Un brote',1),
(940078,930029,'Una piedra',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950029,930029,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930030,920008,'Tomás puso la maceta dentro de un armario oscuro.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940079,930030,'Falso',1),
(940080,930030,'Verdadero',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950030,930030,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930031,920008,'¿Por qué crees que Luna y Tomás sonrieron al ver el brote?',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950031,930031,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930032,920008,'Escribe una acción de Luna y una acción de Tomás que ayudaron a la planta.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950032,930032,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920009,'PRUEBA',910003,'Prueba de cierre: Leemos el cuento de Luna y la semilla',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930033,920009,'¿Qué hizo Luna primero?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940081,930033,'Sonrió con Tomás',0),
(940082,930033,'Regó una planta grande',0),
(940083,930033,'Encontró una semilla',1),
(940084,930033,'Vio un brote',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950033,930033,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930034,920009,'Marca las acciones que sí ocurrieron en el cuento.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940085,930034,'Luna dejó de cuidar la planta',0),
(940086,930034,'Luna puso la semilla en tierra',1),
(940087,930034,'Tomás acercó la maceta a una ventana',1),
(940088,930034,'La semilla creció en una caja sin tierra',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950034,930034,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930035,920009,'El cuento termina con Luna y Tomás cuidando la planta.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940089,930035,'Verdadero',1),
(940090,930035,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950035,930035,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930036,920009,'Cuenta con tus palabras el inicio y el final del cuento.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950036,930036,id_tipo_material,'Lee y observa: Leemos el cuento de Luna y la semilla','Luna encontró una semilla en el patio de la escuela. La puso en una maceta con tierra y la regó cada mañana. Su amigo Tomás dejó la maceta cerca de una ventana. Después de varios días apareció un brote. Luna y Tomás sonrieron y siguieron cuidando la planta.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920010,'ACTIVIDAD',910004,'Exploramos: Jugamos con sonidos, sílabas y oraciones',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930037,920010,'¿Qué palabra comienza con el sonido /m/?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940091,930037,'Luna',0),
(940092,930037,'Mesa',1),
(940093,930037,'Sol',0),
(940094,930037,'Pato',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950037,930037,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930038,920010,'¿Cómo se separa la palabra casa en sílabas?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940095,930038,'ca-sa',1),
(940096,930038,'c-as-a',0),
(940097,930038,'cas-a',0),
(940098,930038,'casa-sa',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950038,930038,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930039,920010,'Marca las palabras que comienzan con la letra p.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940099,930039,'Pelota',1),
(940100,930039,'Mesa',0),
(940101,930039,'Luna',0),
(940102,930039,'Pato',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950039,930039,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930040,920010,'La palabra sol tiene una sola sílaba.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940103,930040,'Verdadero',1),
(940104,930040,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950040,930040,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920011,'ACTIVIDAD',910004,'Aplicamos y explicamos: Jugamos con sonidos, sílabas y oraciones',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930041,920011,'¿Qué palabra se forma al unir ma y no?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940105,930041,'Mamá',0),
(940106,930041,'Mano',1),
(940107,930041,'Mono',0),
(940108,930041,'Mapa',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950041,930041,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930042,920011,'Mesa y mochila comienzan con la misma letra.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940109,930042,'Verdadero',1),
(940110,930042,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950042,930042,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930043,920011,'Escribe una oración que cuente algo sobre tu mascota o un animal que te guste.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950043,930043,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930044,920011,'Escribe tu nombre y otra palabra que comience con la misma letra.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950044,930044,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920012,'PRUEBA',910004,'Prueba de cierre: Jugamos con sonidos, sílabas y oraciones',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930045,920012,'¿Cuántas sílabas tiene mariposa: ma-ri-po-sa?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940111,930045,'5',0),
(940112,930045,'4',1),
(940113,930045,'2',0),
(940114,930045,'3',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950045,930045,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930046,920012,'Marca las palabras que tienen dos sílabas.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940115,930046,'Casa',1),
(940116,930046,'Mesa',1),
(940117,930046,'Sol',0),
(940118,930046,'Mariposa',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950046,930046,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930047,920012,'Una oración escrita puede comenzar con mayúscula y terminar con punto.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940119,930047,'Falso',0),
(940120,930047,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950047,930047,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930048,920012,'Ordena estas palabras y escribe una oración: juega / Ana / en el patio.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950048,930048,id_tipo_material,'Lee y observa: Jugamos con sonidos, sílabas y oraciones','En la sala hay una mesa, una mochila y un mapa. En el patio vemos una mariposa. Di las palabras lentamente y acompaña cada sílaba con una palmada. Para escribir, piensa primero qué quieres contar.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920013,'ACTIVIDAD',910005,'Exploramos: El tiempo en nuestra vida cotidiana',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930049,920013,'¿Qué día viene después del lunes?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940121,930049,'Martes',1),
(940122,930049,'Domingo',0),
(940123,930049,'Viernes',0),
(940124,930049,'Jueves',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950049,930049,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930050,920013,'Según el texto, ¿qué hace Sofía el miércoles?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940125,930050,'Lleva un libro',0),
(940126,930050,'Riega el huerto',0),
(940127,930050,'Comparte una lectura',0),
(940128,930050,'Dibuja',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950050,930050,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930051,920013,'Marca los días que aparecen como fin de semana en el texto.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940129,930051,'Martes',0),
(940130,930051,'Jueves',0),
(940131,930051,'Sábado',1),
(940132,930051,'Domingo',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950051,930051,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930052,920013,'El viernes viene después del jueves.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940133,930052,'Falso',0),
(940134,930052,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950052,930052,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920014,'ACTIVIDAD',910005,'Aplicamos y explicamos: El tiempo en nuestra vida cotidiana',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930053,920014,'Si hoy es martes, ¿qué día fue ayer?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940135,930053,'Lunes',1),
(940136,930053,'Miércoles',0),
(940137,930053,'Jueves',0),
(940138,930053,'Domingo',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950053,930053,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930054,920014,'El día que viene inmediatamente después del viernes es el lunes.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940139,930054,'Falso',1),
(940140,930054,'Verdadero',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950054,930054,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930055,920014,'Escribe dos actividades de tu mañana y ordénalas usando primero y después.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950055,930055,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930056,920014,'Cuenta una cosa que hacías cuando eras más pequeño y una que haces ahora.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950056,930056,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920015,'PRUEBA',910005,'Prueba de cierre: El tiempo en nuestra vida cotidiana',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930057,920015,'¿Qué día está entre el miércoles y el viernes?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940141,930057,'Jueves',1),
(940142,930057,'Lunes',0),
(940143,930057,'Sábado',0),
(940144,930057,'Martes',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950057,930057,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930058,920015,'Marca las afirmaciones que coinciden con la semana de Sofía.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940145,930058,'El viernes comparte una lectura',1),
(940146,930058,'El lunes juega a la pelota',0),
(940147,930058,'El jueves dibuja',0),
(940148,930058,'El martes riega el huerto',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950058,930058,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930059,920015,'Ayer, hoy y mañana nos ayudan a ordenar acontecimientos en el tiempo.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940149,930059,'Verdadero',1),
(940150,930059,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950059,930059,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930060,920015,'Ordena y escribe estas acciones: dormir de noche, desayunar, almorzar.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950060,930060,id_tipo_material,'Lee y observa: El tiempo en nuestra vida cotidiana','La semana de Sofía: el lunes lleva un libro a la escuela; el martes riega el huerto; el miércoles dibuja; el jueves juega a la pelota y el viernes comparte una lectura. El sábado y el domingo descansa y realiza actividades con su familia.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920016,'ACTIVIDAD',910006,'Exploramos: Convivimos y cuidamos nuestra comunidad',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930061,920016,'¿Qué debemos hacer cuando un compañero está hablando?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940151,930061,'Gritar para interrumpir',0),
(940152,930061,'Empujarlo',0),
(940153,930061,'Quitarle sus materiales',0),
(940154,930061,'Escuchar con atención',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950061,930061,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930062,920016,'¿Dónde corresponde dejar un envoltorio en la plaza?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940155,930062,'En el suelo',0),
(940156,930062,'En la fuente de agua',0),
(940157,930062,'En un basurero',1),
(940158,930062,'Entre las plantas',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950062,930062,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930063,920016,'Marca las acciones que ayudan a convivir.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940159,930063,'Romper materiales compartidos',0),
(940160,930063,'Pedir las cosas con respeto',1),
(940161,930063,'Respetar los turnos',1),
(940162,930063,'Burlarse de otros',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950063,930063,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930064,920016,'Los acuerdos del curso ayudan a cuidarnos y aprender juntos.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940163,930064,'Verdadero',1),
(940164,930064,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950064,930064,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920017,'ACTIVIDAD',910006,'Aplicamos y explicamos: Convivimos y cuidamos nuestra comunidad',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930065,920017,'Dos compañeros quieren el mismo libro. ¿Qué pueden hacer?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940165,930065,'Romper el libro',0),
(940166,930065,'Golpearse',0),
(940167,930065,'Esconder todos los libros',0),
(940168,930065,'Acordar turnos para leer',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950065,930065,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930066,920017,'Todas las familias deben estar formadas por las mismas personas.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940169,930066,'Verdadero',0),
(940170,930066,'Falso',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950066,930066,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930067,920017,'Propón un acuerdo para cuidar los materiales de tu sala.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950067,930067,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930068,920017,'¿Qué harías si ves a un compañero triste porque no lo dejan jugar?',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950068,930068,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920018,'PRUEBA',910006,'Prueba de cierre: Convivimos y cuidamos nuestra comunidad',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930069,920018,'¿A quién puedes pedir ayuda si un conflicto te hace sentir inseguro?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940171,930069,'A nadie',0),
(940172,930069,'Solo a alguien desconocido',0),
(940173,930069,'A quien te amenaza',0),
(940174,930069,'A una persona adulta de confianza',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950069,930069,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930070,920018,'Marca las acciones que cuidan un espacio compartido.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940175,930070,'Rayar los bancos',0),
(940176,930070,'Romper los juegos',0),
(940177,930070,'Recoger la basura',1),
(940178,930070,'Cuidar las plantas',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950070,930070,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930071,920018,'Podemos tener gustos diferentes y tratarnos con respeto.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940179,930071,'Falso',0),
(940180,930071,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950071,930071,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930072,920018,'Explica por qué es importante respetar los turnos al jugar.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950072,930072,id_tipo_material,'Lee y observa: Convivimos y cuidamos nuestra comunidad','En el curso de Elisa acordaron escuchar cuando alguien habla, cuidar los libros y pedir los materiales con respeto. Si hay un problema, conversan y buscan ayuda de una persona adulta. En la plaza del barrio usan basureros y cuidan las plantas.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920019,'ACTIVIDAD',910007,'Exploramos: Seres vivos y sus necesidades',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930073,920019,'¿Cuál de estos elementos es un ser vivo?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940181,930073,'Una banca',0),
(940182,930073,'Una pelota',0),
(940183,930073,'Un árbol',1),
(940184,930073,'Una piedra',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950073,930073,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930074,920019,'¿Qué necesita una planta para crecer?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940185,930074,'Pintura en sus hojas',0),
(940186,930074,'Agua y luz adecuadas',1),
(940187,930074,'Solo juguetes',0),
(940188,930074,'Solo oscuridad',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950074,930074,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930075,920019,'Marca los seres vivos.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940189,930075,'Un gato',1),
(940190,930075,'Una planta de porotos',1),
(940191,930075,'Una piedra',0),
(940192,930075,'Una mochila',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950075,930075,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930076,920019,'Los seres vivos cambian y crecen durante su vida.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940193,930076,'Falso',0),
(940194,930076,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950076,930076,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920020,'ACTIVIDAD',910007,'Aplicamos y explicamos: Seres vivos y sus necesidades',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930077,920020,'¿Qué acción ayuda a cuidar a un gato?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940195,930077,'Asustarlo',0),
(940196,930077,'Darle solo dulces',0),
(940197,930077,'Darle agua limpia y alimento adecuado',1),
(940198,930077,'Dejarlo siempre sin agua',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950077,930077,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930078,920020,'Una piedra necesita comer para vivir.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940199,930078,'Falso',1),
(940200,930078,'Verdadero',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950078,930078,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930079,920020,'Nombra una planta que conozcas y explica cómo la cuidarías.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950079,930079,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930080,920020,'Escribe una diferencia entre un árbol y una banca.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950080,930080,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920021,'PRUEBA',910007,'Prueba de cierre: Seres vivos y sus necesidades',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930081,920021,'La tierra de una maceta está muy seca. ¿Qué puedes hacer para cuidar la planta?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940201,930081,'Cubrirla con plástico sin aire',0),
(940202,930081,'Pintar la tierra',0),
(940203,930081,'Regarla con una cantidad adecuada de agua',1),
(940204,930081,'Arrancar sus hojas',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950081,930081,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930082,920021,'Marca las necesidades de un gato.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940205,930082,'Cuadernos',0),
(940206,930082,'Agua',1),
(940207,930082,'Alimento adecuado',1),
(940208,930082,'Un teléfono',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950082,930082,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930083,920021,'Las plantas son seres vivos aunque no caminen de un lugar a otro.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940209,930083,'Verdadero',1),
(940210,930083,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950083,930083,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930084,920021,'Explica por qué un juguete con forma de perro no es un ser vivo.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950084,930084,id_tipo_material,'Lee y observa: Seres vivos y sus necesidades','En el patio de la escuela hay un árbol, un gato, piedras y una banca. La planta de porotos crece en una maceta con tierra. El curso la ubica donde recibe luz y la riega sin encharcarla. El gato bebe agua y come alimento adecuado para gatos.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920022,'ACTIVIDAD',910008,'Exploramos: Nuestros sentidos y el cuidado del cuerpo',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930085,920022,'¿Qué parte del cuerpo usamos principalmente para ver una flor?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940211,930085,'La lengua',0),
(940212,930085,'Los ojos',1),
(940213,930085,'Los oídos',0),
(940214,930085,'La nariz',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950085,930085,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930086,920022,'¿Qué sentido usamos para escuchar el canto de un pájaro?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940215,930086,'Audición',1),
(940216,930086,'Gusto',0),
(940217,930086,'Olfato',0),
(940218,930086,'Vista',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950086,930086,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930087,920022,'Marca los hábitos que ayudan a cuidar el cuerpo.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940219,930087,'Dormir lo suficiente',1),
(940220,930087,'Comer con las manos sucias',0),
(940221,930087,'Escuchar sonidos muy fuertes de cerca',0),
(940222,930087,'Lavarse las manos antes de comer',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950087,930087,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930088,920022,'La nariz nos ayuda a percibir olores.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940223,930088,'Verdadero',1),
(940224,930088,'Falso',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950088,930088,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920023,'ACTIVIDAD',910008,'Aplicamos y explicamos: Nuestros sentidos y el cuidado del cuerpo',1,3,NULL);
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930089,920023,'¿Qué sentido ayuda a notar si una tela es suave?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940225,930089,'Vista solamente',0),
(940226,930089,'Tacto',1),
(940227,930089,'Audición',0),
(940228,930089,'Olfato',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950089,930089,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930090,920023,'Es seguro probar cualquier líquido desconocido para saber qué es.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940229,930090,'Verdadero',0),
(940230,930090,'Falso',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950090,930090,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930091,920023,'Cuenta dos momentos del día en que es importante lavarse las manos.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950091,930091,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930092,920023,'Nombra un sonido de tu entorno y explica cómo cuidas tus oídos.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950092,930092,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES (920024,'PRUEBA',910008,'Prueba de cierre: Nuestros sentidos y el cuidado del cuerpo',1,3,TIMESTAMP(CURRENT_DATE(), '09:00:00'));
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930093,920024,'¿Qué parte del cuerpo nos ayuda principalmente a distinguir sabores?',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_UNICA';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940231,930093,'Las rodillas',0),
(940232,930093,'La lengua',1),
(940233,930093,'Los oídos',0),
(940234,930093,'El cabello',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950093,930093,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930094,920024,'Marca las relaciones correctas.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940235,930094,'Ojos: vista',1),
(940236,930094,'Oídos: audición',1),
(940237,930094,'Nariz: tacto',0),
(940238,930094,'Lengua: audición',0);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950094,930094,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930095,920024,'Debemos pedir ayuda a una persona adulta antes de tocar algo que podría quemarnos.',id_tipo_pregunta,1 FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO';
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(940239,930095,'Falso',0),
(940240,930095,'Verdadero',1);
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950095,930095,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';
INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo) SELECT 930096,920024,'Explica una acción que realizarías para cuidar tus ojos o tus oídos.',id_tipo_pregunta,2 FROM tipos_pregunta WHERE codigo='DESARROLLO';
INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo) SELECT 950096,930096,id_tipo_material,'Lee y observa: Nuestros sentidos y el cuidado del cuerpo','En una visita al patio, Nico mira una flor, escucha un pájaro y huele una hoja de menta con ayuda de su profesora. Antes de comer, se lava las manos. No prueba plantas ni sustancias desconocidas y evita acercarse a sonidos muy fuertes.',1 FROM tipos_material WHERE codigo='TEXTO';

--changeset practika:content-062-mvp-history-subject-id context:@dev
-- content-061 may already be applied: repair its two History units without changing its checksum.
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:2 SELECT COUNT(*) FROM unidades WHERE (id_unidad=910005 AND id_objetivo=910005 AND id_asignatura IN (4,5)) OR (id_unidad=910006 AND id_objetivo=910006 AND id_asignatura IN (4,5))
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM unidades_cursos uc JOIN unidades u ON u.id_unidad=uc.id_unidad WHERE u.id_unidad IN (910005,910006) AND u.id_asignatura<>5
UPDATE unidades SET id_asignatura=5 WHERE id_unidad IN (910005,910006) AND id_asignatura=4;

