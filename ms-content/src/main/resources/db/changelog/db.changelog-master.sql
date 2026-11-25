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

--changeset practika:content-048-preguntas-evaluation-contract dbms:mysql
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

--changeset practika:content-048-preguntas-evaluation-contract-mariadb dbms:mariadb
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM preguntas WHERE id_evaluacion IS NULL
ALTER TABLE `preguntas`
  DROP FOREIGN KEY `fk_preguntas_actividades`,
  DROP FOREIGN KEY `fk_preguntas_pruebas`,
  DROP CONSTRAINT `chk_pregunta_destino`,
  DROP COLUMN `id_actividad`,
  DROP COLUMN `id_prueba`,
  MODIFY COLUMN `id_evaluacion` INT NOT NULL,
  ADD CONSTRAINT `fk_pregunta_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE;

--changeset practika:content-049-materiales-evaluation-column
ALTER TABLE `materiales` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-050-materiales-evaluation-copy
UPDATE `materiales` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;

--changeset practika:content-051-materiales-evaluation-contract dbms:mysql
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM materiales WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `materiales`
  DROP FOREIGN KEY `fk_materiales_actividades`,
  DROP CHECK `chk_material_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_material_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_materiales_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-051-materiales-evaluation-contract-mariadb dbms:mariadb
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM materiales WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `materiales`
  DROP FOREIGN KEY `fk_materiales_actividades`,
  DROP CONSTRAINT `chk_material_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_material_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_materiales_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-052-archivos_recursos-evaluation-column
ALTER TABLE `archivos_recursos` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-053-archivos_recursos-evaluation-copy
UPDATE `archivos_recursos` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;

--changeset practika:content-054-archivos_recursos-evaluation-contract dbms:mysql
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM archivos_recursos WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `archivos_recursos`
  DROP FOREIGN KEY `fk_archivos_recursos_actividad`,
  DROP CHECK `chk_archivo_recurso_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_archivo_recurso_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_archivos_recursos_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-054-archivos_recursos-evaluation-contract-mariadb dbms:mariadb
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM archivos_recursos WHERE id_evaluacion IS NULL AND id_actividad IS NOT NULL
ALTER TABLE `archivos_recursos`
  DROP FOREIGN KEY `fk_archivos_recursos_actividad`,
  DROP CONSTRAINT `chk_archivo_recurso_destino`,
  DROP COLUMN `id_actividad`,
  ADD CONSTRAINT `fk_archivo_recurso_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_archivos_recursos_evaluation_owner` CHECK ((`id_evaluacion` IS NOT NULL) <> (`id_pregunta` IS NOT NULL));

--changeset practika:content-055-evaluaciones_asignadas-evaluation-column
ALTER TABLE `evaluaciones_asignadas` ADD COLUMN `id_evaluacion` INT NULL;

--changeset practika:content-056-evaluaciones_asignadas-evaluation-copy
UPDATE `evaluaciones_asignadas` t JOIN `evaluaciones` e ON e.`tipo`='ACTIVIDAD' AND e.`id_legacy`=t.`id_actividad` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_actividad` IS NOT NULL;
UPDATE `evaluaciones_asignadas` t JOIN `evaluaciones` e ON e.`tipo`='PRUEBA' AND e.`id_legacy`=t.`id_prueba` SET t.`id_evaluacion`=e.`id_evaluacion` WHERE t.`id_prueba` IS NOT NULL;

--changeset practika:content-057-evaluaciones_asignadas-evaluation-contract dbms:mysql
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

--changeset practika:content-057-evaluaciones_asignadas-evaluation-contract-mariadb dbms:mariadb
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM evaluaciones_asignadas WHERE id_evaluacion IS NULL
ALTER TABLE `evaluaciones_asignadas`
  ADD CONSTRAINT `uq_publicacion_evaluacion_version` UNIQUE (`id_asignacion`,`id_evaluacion`,`version`),
  DROP FOREIGN KEY `fk_evaluaciones_actividad`,
  DROP FOREIGN KEY `fk_evaluaciones_prueba`,
  DROP CONSTRAINT `chk_evaluacion_destino`,
  DROP INDEX `uq_evaluacion_actividad_version`,
  DROP INDEX `uq_evaluacion_prueba_version`,
  DROP COLUMN `id_actividad`,
  DROP COLUMN `id_prueba`,
  MODIFY COLUMN `id_evaluacion` INT NOT NULL,
  ADD CONSTRAINT `fk_publicacion_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluaciones` (`id_evaluacion`);

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

--changeset practika:content-063-four-subject-image-units context:@dev
-- Align the development catalog with the 16 supplied unit thumbnails.
UPDATE unidades SET titulo='Cálculo y operaciones', descripcion='Resuelve operaciones con números naturales y aplica estrategias de cálculo en problemas cotidianos.' WHERE id_unidad=910001;
UPDATE unidades SET titulo='Geometría', descripcion='Reconoce figuras planas, sus elementos y sus propiedades en el entorno.' WHERE id_unidad=910002;
UPDATE unidades SET titulo='Lectura', descripcion='Comprende textos narrativos e informativos, identifica ideas y realiza inferencias.' WHERE id_unidad=910003;
UPDATE unidades SET titulo='Escritura', descripcion='Planifica, redacta y revisa textos para comunicar ideas con claridad.' WHERE id_unidad=910004;
UPDATE unidades SET titulo='Civilizaciones antiguas', descripcion='Explora las primeras civilizaciones, su organización y sus aportes culturales.' WHERE id_unidad=910005;
UPDATE unidades SET titulo='Exploraciones', descripcion='Conoce viajes de exploración y analiza sus encuentros e impactos.' WHERE id_unidad=910006;
UPDATE unidades SET titulo='Biología', descripcion='Investiga los seres vivos, sus necesidades, ciclos e interacciones.' WHERE id_unidad=910007;
UPDATE unidades SET titulo='Microscopía', descripcion='Observa muestras y descubre estructuras pequeñas usando instrumentos científicos.' WHERE id_unidad=910008;
INSERT INTO unidades (id_unidad,id_asignatura,id_objetivo,titulo,descripcion) VALUES
(910009,1,910009,'Cuerpos geométricos','Identifica prismas, pirámides, cilindros, conos y esferas en objetos del entorno.'),
(910010,1,910010,'Estadística','Organiza datos en tablas y gráficos, y comunica conclusiones sencillas.'),
(910011,2,910011,'Literatura','Lee obras literarias y reconoce personajes, ambientes, temas y recursos.'),
(910012,2,910012,'Comunicación','Expresa ideas de forma oral y escrita considerando propósito y audiencia.'),
(910013,3,910013,'Química','Explora materiales, sus propiedades y los cambios que experimentan.'),
(910014,3,910014,'Física','Investiga movimiento, fuerzas, energía y fenómenos físicos cotidianos.'),
(910015,5,910015,'Roma antigua','Conoce la sociedad romana, su expansión y su legado en el mundo actual.'),
(910016,5,910016,'Cartografía','Lee y crea mapas usando referencias, símbolos y escalas sencillas.');
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Números y operaciones hasta el 20','Cálculo y operaciones') WHERE id_unidad=910001;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Figuras y posiciones a nuestro alrededor','Geometría') WHERE id_unidad=910002;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Leemos el cuento de Luna y la semilla','Lectura') WHERE id_unidad=910003;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Jugamos con sonidos, sílabas y oraciones','Escritura') WHERE id_unidad=910004;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'El tiempo en nuestra vida cotidiana','Civilizaciones antiguas') WHERE id_unidad=910005;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Convivimos y cuidamos nuestra comunidad','Exploraciones') WHERE id_unidad=910006;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Seres vivos y sus necesidades','Biología') WHERE id_unidad=910007;
UPDATE evaluaciones SET titulo=REPLACE(titulo,'Nuestros sentidos y el cuidado del cuerpo','Microscopía') WHERE id_unidad=910008;

--changeset practika:content-064-image-unit-learning-content context:@dev
-- Add complete practice and assessment material for the eight new units.
INSERT INTO evaluaciones (id_evaluacion,tipo,id_unidad,titulo,estado_activo,cantidad_intentos,fecha_aplicacion) VALUES
(921001,'ACTIVIDAD',910009,'Exploramos: Cuerpos geométricos',1,3,NULL),(921002,'PRUEBA',910009,'Prueba: Cuerpos geométricos',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921003,'ACTIVIDAD',910010,'Exploramos: Estadística',1,3,NULL),(921004,'PRUEBA',910010,'Prueba: Estadística',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921005,'ACTIVIDAD',910011,'Exploramos: Literatura',1,3,NULL),(921006,'PRUEBA',910011,'Prueba: Literatura',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921007,'ACTIVIDAD',910012,'Exploramos: Comunicación',1,3,NULL),(921008,'PRUEBA',910012,'Prueba: Comunicación',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921009,'ACTIVIDAD',910013,'Exploramos: Química',1,3,NULL),(921010,'PRUEBA',910013,'Prueba: Química',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921011,'ACTIVIDAD',910014,'Exploramos: Física',1,3,NULL),(921012,'PRUEBA',910014,'Prueba: Física',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921013,'ACTIVIDAD',910015,'Exploramos: Roma antigua',1,3,NULL),(921014,'PRUEBA',910015,'Prueba: Roma antigua',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00')),
(921015,'ACTIVIDAD',910016,'Exploramos: Cartografía',1,3,NULL),(921016,'PRUEBA',910016,'Prueba: Cartografía',1,2,TIMESTAMP(CURRENT_DATE(),'09:00:00'));

INSERT INTO preguntas (id_pregunta,id_evaluacion,texto_pregunta,id_tipo_pregunta,puntaje_maximo)
SELECT 931001+(e.id_evaluacion-921001)*4+q.qn,e.id_evaluacion,q.texto,t.id_tipo_pregunta,1
FROM evaluaciones e
JOIN (
 SELECT 910009 unidad,1 qn,'¿Qué cuerpo tiene seis caras cuadradas iguales?' texto UNION ALL SELECT 910009,2,'¿Qué forma tiene una lata de bebida?' UNION ALL SELECT 910009,3,'¿Qué cuerpo tiene una superficie curva y dos bases circulares?' UNION ALL SELECT 910009,4,'¿Cuántas caras tiene un cubo?'
 UNION ALL SELECT 910010,1,'En una encuesta, ¿para qué sirve una tabla de conteo?' UNION ALL SELECT 910010,2,'¿Qué gráfico permite comparar cantidades con barras?' UNION ALL SELECT 910010,3,'Si 8 de 12 estudiantes prefieren leer, ¿qué actividad fue la más elegida?' UNION ALL SELECT 910010,4,'¿Qué debe incluir un gráfico para entender sus datos?'
 UNION ALL SELECT 910011,1,'¿Quién es el personaje que realiza las acciones principales de un relato?' UNION ALL SELECT 910011,2,'¿Qué elemento indica dónde ocurre una historia?' UNION ALL SELECT 910011,3,'¿Qué es una fábula?' UNION ALL SELECT 910011,4,'¿Qué información ayuda a inferir cómo se siente un personaje?'
 UNION ALL SELECT 910012,1,'¿Qué conviene hacer antes de exponer un tema frente al curso?' UNION ALL SELECT 910012,2,'¿Qué respuesta demuestra escucha activa?' UNION ALL SELECT 910012,3,'¿Qué saludo es más adecuado en una carta formal?' UNION ALL SELECT 910012,4,'¿Para qué sirve ordenar las ideas al comunicar?'
 UNION ALL SELECT 910013,1,'¿Cuál es un cambio de estado del agua líquida al vapor?' UNION ALL SELECT 910013,2,'¿Qué instrumento se usa para medir la masa?' UNION ALL SELECT 910013,3,'¿Qué propiedad permite distinguir un material de otro?' UNION ALL SELECT 910013,4,'¿Qué ocurre al mezclar agua y sal y revolver?'
 UNION ALL SELECT 910014,1,'¿Qué fuerza hace caer los objetos hacia el suelo?' UNION ALL SELECT 910014,2,'¿Qué unidad se usa comúnmente para medir el tiempo?' UNION ALL SELECT 910014,3,'¿Qué puede cambiar una fuerza aplicada a un objeto?' UNION ALL SELECT 910014,4,'¿Cuál es una fuente natural de luz y energía térmica?'
 UNION ALL SELECT 910015,1,'¿Cuál era la ciudad principal del Imperio romano?' UNION ALL SELECT 910015,2,'¿Cómo se llamaba la plaza pública central romana?' UNION ALL SELECT 910015,3,'¿Qué lengua hablaban los antiguos romanos?' UNION ALL SELECT 910015,4,'¿Qué construcción romana llevaba agua hacia las ciudades?'
 UNION ALL SELECT 910016,1,'¿Qué representa la leyenda de un mapa?' UNION ALL SELECT 910016,2,'¿Qué punto cardinal suele ubicarse arriba en los mapas?' UNION ALL SELECT 910016,3,'¿Para qué sirve la escala de un mapa?' UNION ALL SELECT 910016,4,'¿Qué instrumento ayuda a orientarse señalando el norte?'
) q ON q.unidad=e.id_unidad
JOIN tipos_pregunta t ON t.codigo='SELECCION_UNICA'
WHERE e.id_evaluacion BETWEEN 921001 AND 921016;

INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta)
SELECT 941001+(p.id_pregunta-931001)*4+n.opn,p.id_pregunta,
CASE n.opn
 WHEN 1 THEN CASE MOD(p.id_pregunta-931001,4)
  WHEN 0 THEN CASE FLOOR((p.id_pregunta-931001)/8) WHEN 0 THEN 'Cubo' WHEN 1 THEN 'El título' WHEN 2 THEN 'El protagonista' WHEN 3 THEN 'Preparar y ordenar las ideas' WHEN 4 THEN 'Evaporación' WHEN 5 THEN 'Gravedad' WHEN 6 THEN 'Roma' ELSE 'Los símbolos y su significado' END
  WHEN 1 THEN CASE FLOOR((p.id_pregunta-931001)/8) WHEN 0 THEN 'Cilindro' WHEN 1 THEN 'Gráfico de barras' WHEN 2 THEN 'El ambiente' WHEN 3 THEN 'Comprender el mensaje' WHEN 4 THEN 'Balanza' WHEN 5 THEN 'Minuto' WHEN 6 THEN 'El foro' ELSE 'El norte' END
  WHEN 2 THEN CASE FLOOR((p.id_pregunta-931001)/8) WHEN 0 THEN 'Cilindro' WHEN 1 THEN 'Leer las preferencias' WHEN 2 THEN 'Un relato con moraleja' WHEN 3 THEN 'Escuchar y responder al tema' WHEN 4 THEN 'Color' WHEN 5 THEN 'La velocidad' WHEN 6 THEN 'Latín' ELSE 'Calcular distancias reales' END
  ELSE CASE FLOOR((p.id_pregunta-931001)/8) WHEN 0 THEN '6' WHEN 1 THEN 'Título, categorías y datos' WHEN 2 THEN 'Las acciones y palabras del relato' WHEN 3 THEN 'Expresar ideas con claridad' WHEN 4 THEN 'Se forma una disolución' WHEN 5 THEN 'El movimiento o la forma' WHEN 6 THEN 'Acueducto' ELSE 'Brújula' END END
 WHEN 2 THEN CASE MOD(p.id_pregunta-931001,4) WHEN 0 THEN 'Esfera' WHEN 1 THEN 'Solo para decorar' WHEN 2 THEN 'El autor' WHEN 3 THEN 'Hablar lo más rápido posible' WHEN 4 THEN 'Congelación' WHEN 5 THEN 'Magnetismo' WHEN 6 THEN 'El coliseo' WHEN 7 THEN 'La escala' END
 WHEN 3 THEN CASE MOD(p.id_pregunta-931001,4) WHEN 0 THEN 'Cono' WHEN 1 THEN 'Un dibujo sin datos' WHEN 2 THEN 'El narrador' WHEN 3 THEN 'Cambiar de tema' WHEN 4 THEN 'Combustión' WHEN 5 THEN 'Electricidad' WHEN 6 THEN 'El senado' WHEN 7 THEN 'El clima' END
 ELSE CASE MOD(p.id_pregunta-931001,4) WHEN 0 THEN 'Pirámide' WHEN 1 THEN 'Una lista sin cantidades' WHEN 2 THEN 'El ilustrador' WHEN 3 THEN 'Interrumpir para terminar antes' WHEN 4 THEN 'Fusión' WHEN 5 THEN 'Sonido' WHEN 6 THEN 'El acueducto' WHEN 7 THEN 'La población' END END,
IF(n.opn=1,1,0)
FROM preguntas p CROSS JOIN (SELECT 1 opn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
WHERE p.id_pregunta BETWEEN 931001 AND 931064;

INSERT INTO materiales (id_material,id_pregunta,id_tipo_material,titulo,contenido_texto,activo)
SELECT 951001+(p.id_pregunta-931001),p.id_pregunta,t.id_tipo_material,
CONCAT('Lee y observa: ',u.titulo),
CONCAT('En esta actividad explorarás ',LOWER(u.titulo),'. Observa los ejemplos, relaciona la información con lo que ya sabes y explica cómo llegaste a tu respuesta.'),1
FROM preguntas p JOIN evaluaciones e ON e.id_evaluacion=p.id_evaluacion
JOIN unidades u ON u.id_unidad=e.id_unidad JOIN tipos_material t ON t.codigo='TEXTO'
WHERE p.id_pregunta BETWEEN 931001 AND 931064;

--changeset practika:content-065-unit-catalog-visibility
-- Retiring a catalog unit must not erase publications or student history.
ALTER TABLE unidades ADD COLUMN activo BOOLEAN NOT NULL DEFAULT 1;

--changeset practika:content-066-reviewed-questions-and-answers context:@dev
-- Explicit question/answer associations replace the old modulo-based alternatives.
-- Published snapshots and real submissions keep their original questions and options.
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:16 SELECT COUNT(*) FROM unidades WHERE id_unidad BETWEEN 910001 AND 910016
--precondition-sql-check expectedResult:40 SELECT COUNT(*) FROM evaluaciones WHERE id_evaluacion IN (920001,920002,920003,920004,920005,920006,920007,920008,920009,920010,920011,920012,920013,920014,920015,920016,920017,920018,920019,920020,920021,920022,920023,920024,921001,921002,921003,921004,921005,921006,921007,921008,921009,921010,921011,921012,921013,921014,921015,921016)
--precondition-sql-check expectedResult:160 SELECT COUNT(*) FROM preguntas WHERE id_pregunta IN (930001,930002,930003,930004,930005,930006,930007,930008,930009,930010,930011,930012,930013,930014,930015,930016,930017,930018,930019,930020,930021,930022,930023,930024,930025,930026,930027,930028,930029,930030,930031,930032,930033,930034,930035,930036,930037,930038,930039,930040,930041,930042,930043,930044,930045,930046,930047,930048,930049,930050,930051,930052,930053,930054,930055,930056,930057,930058,930059,930060,930061,930062,930063,930064,930065,930066,930067,930068,930069,930070,930071,930072,930073,930074,930075,930076,930077,930078,930079,930080,930081,930082,930083,930084,930085,930086,930087,930088,930089,930090,930091,930092,930093,930094,930095,930096,931002,931003,931004,931005,931006,931007,931008,931009,931010,931011,931012,931013,931014,931015,931016,931017,931018,931019,931020,931021,931022,931023,931024,931025,931026,931027,931028,931029,931030,931031,931032,931033,931034,931035,931036,931037,931038,931039,931040,931041,931042,931043,931044,931045,931046,931047,931048,931049,931050,931051,931052,931053,931054,931055,931056,931057,931058,931059,931060,931061,931062,931063,931064,931065)
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM opciones WHERE id_opcion BETWEEN 970001 AND 971000
--precondition-sql-check expectedResult:4 SELECT COUNT(*) FROM tipos_pregunta WHERE codigo IN ('SELECCION_UNICA','SELECCION_MULTIPLE','VERDADERO_FALSO','DESARROLLO')
-- Archive only the six original example units. Direct access and history remain available.
UPDATE unidades SET activo=0 WHERE id_unidad BETWEEN 1 AND 6;
-- Retire copies of obsolete fixtures; a teacher can select the reviewed source again.
UPDATE evaluaciones_asignadas p JOIN evaluaciones e ON e.id_evaluacion=p.id_evaluacion SET p.activa=0
WHERE e.id_evaluacion IN (920001,920002,920003,920004,920005,920006,920007,920008,920009,920010,920011,920012,920013,920014,920015,920016,920017,920018,920019,920020,920021,920022,920023,920024,921001,921002,921003,921004,921005,921006,921007,921008,921009,921010,921011,921012,921013,921014,921015,921016) OR (e.tipo='ACTIVIDAD' AND e.id_legacy BETWEEN 1 AND 13) OR (e.tipo='PRUEBA' AND e.id_legacy BETWEEN 1 AND 12);
DELETE FROM opciones WHERE id_pregunta IN (930001,930002,930003,930004,930005,930006,930007,930008,930009,930010,930011,930012,930013,930014,930015,930016,930017,930018,930019,930020,930021,930022,930023,930024,930025,930026,930027,930028,930029,930030,930031,930032,930033,930034,930035,930036,930037,930038,930039,930040,930041,930042,930043,930044,930045,930046,930047,930048,930049,930050,930051,930052,930053,930054,930055,930056,930057,930058,930059,930060,930061,930062,930063,930064,930065,930066,930067,930068,930069,930070,930071,930072,930073,930074,930075,930076,930077,930078,930079,930080,930081,930082,930083,930084,930085,930086,930087,930088,930089,930090,930091,930092,930093,930094,930095,930096,931002,931003,931004,931005,931006,931007,931008,931009,931010,931011,931012,931013,931014,931015,931016,931017,931018,931019,931020,931021,931022,931023,931024,931025,931026,931027,931028,931029,931030,931031,931032,931033,931034,931035,931036,931037,931038,931039,931040,931041,931042,931043,931044,931045,931046,931047,931048,931049,931050,931051,931052,931053,931054,931055,931056,931057,931058,931059,931060,931061,931062,931063,931064,931065);
-- Disable generated support only; user-uploaded resources are preserved. No support is inserted.
UPDATE materiales SET activo=0 WHERE ((id_material BETWEEN 950001 AND 950096) OR (id_material BETWEEN 951001 AND 951100) OR (id_material BETWEEN 960001 AND 960016))
AND id_pregunta IN (930001,930002,930003,930004,930005,930006,930007,930008,930009,930010,930011,930012,930013,930014,930015,930016,930017,930018,930019,930020,930021,930022,930023,930024,930025,930026,930027,930028,930029,930030,930031,930032,930033,930034,930035,930036,930037,930038,930039,930040,930041,930042,930043,930044,930045,930046,930047,930048,930049,930050,930051,930052,930053,930054,930055,930056,930057,930058,930059,930060,930061,930062,930063,930064,930065,930066,930067,930068,930069,930070,930071,930072,930073,930074,930075,930076,930077,930078,930079,930080,930081,930082,930083,930084,930085,930086,930087,930088,930089,930090,930091,930092,930093,930094,930095,930096,931002,931003,931004,931005,931006,931007,931008,931009,931010,931011,931012,931013,931014,931015,931016,931017,931018,931019,931020,931021,931022,931023,931024,931025,931026,931027,931028,931029,931030,931031,931032,931033,931034,931035,931036,931037,931038,931039,931040,931041,931042,931043,931044,931045,931046,931047,931048,931049,931050,931051,931052,931053,931054,931055,931056,931057,931058,931059,931060,931061,931062,931063,931064,931065);

-- Matemática / Cálculo y operaciones
UPDATE unidades SET id_asignatura=1,id_objetivo=910001,titulo='Cálculo y operaciones',descripcion='Resolver sumas, restas y problemas de cantidades hasta 20.',activo=1 WHERE id_unidad=910001;
UPDATE evaluaciones SET titulo='Exploramos: Cálculo y operaciones',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920001;
UPDATE evaluaciones SET titulo='Aplicamos: Cálculo y operaciones',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920002;
UPDATE evaluaciones SET titulo='Prueba de cierre: Cálculo y operaciones',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920003;
UPDATE preguntas SET id_evaluacion=920001,texto_pregunta='Ana tiene 6 manzanas y recibe 3 más. ¿Cuántas manzanas tiene ahora?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930001;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970001,930001,'3',0),
(970002,930001,'8',0),
(970003,930001,'10',0),
(970004,930001,'9',1);
UPDATE preguntas SET id_evaluacion=920001,texto_pregunta='Marca las operaciones cuyo resultado es 10.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930002;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970005,930002,'8 + 3',0),
(970006,930002,'12 - 3',0),
(970007,930002,'6 + 4',1),
(970008,930002,'15 - 5',1);
UPDATE preguntas SET id_evaluacion=920001,texto_pregunta='Si tienes 12 lápices y regalas 4, te quedan 8 lápices.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930003;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970009,930003,'Falso',0),
(970010,930003,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920001,texto_pregunta='Había 14 libros en una mesa. Se prestaron 5. ¿Cuántos quedan? Escribe la operación y el resultado.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930004;
UPDATE preguntas SET id_evaluacion=920002,texto_pregunta='Hay 7 estudiantes en una fila y llegan otros 5. ¿Cuántos estudiantes hay en total?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930005;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970011,930005,'2',0),
(970012,930005,'11',0),
(970013,930005,'13',0),
(970014,930005,'12',1);
UPDATE preguntas SET id_evaluacion=920002,texto_pregunta='Marca los números mayores que 12 y menores que 16.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930006;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970015,930006,'12',0),
(970016,930006,'16',0),
(970017,930006,'13',1),
(970018,930006,'15',1);
UPDATE preguntas SET id_evaluacion=920002,texto_pregunta='La suma 9 + 4 tiene el mismo resultado que 4 + 9.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930007;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970019,930007,'Falso',0),
(970020,930007,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920002,texto_pregunta='En una caja había 8 fichas y en otra había 6. Explica cómo puedes encontrar el total.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930008;
UPDATE preguntas SET id_evaluacion=920003,texto_pregunta='Un bus lleva 18 pasajeros y bajan 7. ¿Cuántos pasajeros quedan?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930009;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970021,930009,'25',0),
(970022,930009,'10',0),
(970023,930009,'12',0),
(970024,930009,'11',1);
UPDATE preguntas SET id_evaluacion=920003,texto_pregunta='Marca las restas cuyo resultado es 7.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930010;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970025,930010,'14 - 6',0),
(970026,930010,'9 - 3',0),
(970027,930010,'12 - 5',1),
(970028,930010,'10 - 3',1);
UPDATE preguntas SET id_evaluacion=920003,texto_pregunta='El resultado de 15 - 6 es 8.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930011;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970029,930011,'Falso',1),
(970030,930011,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=920003,texto_pregunta='Sofía tenía algunas láminas. Recibió 4 y ahora tiene 13. ¿Cuántas tenía antes? Explica tu cálculo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930012;

-- Matemática / Geometría
UPDATE unidades SET id_asignatura=1,id_objetivo=910002,titulo='Geometría',descripcion='Reconocer figuras planas y describir sus lados, vértices y posiciones.',activo=1 WHERE id_unidad=910002;
UPDATE evaluaciones SET titulo='Exploramos: Geometría',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920004;
UPDATE evaluaciones SET titulo='Aplicamos: Geometría',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920005;
UPDATE evaluaciones SET titulo='Prueba de cierre: Geometría',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920006;
UPDATE preguntas SET id_evaluacion=920004,texto_pregunta='¿Qué figura plana tiene tres lados rectos y tres vértices?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930013;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970031,930013,'Círculo',0),
(970032,930013,'Rectángulo',0),
(970033,930013,'Triángulo',1),
(970034,930013,'Cuadrado',0);
UPDATE preguntas SET id_evaluacion=920004,texto_pregunta='Marca las figuras planas que tienen cuatro lados.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930014;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970035,930014,'Círculo',0),
(970036,930014,'Cuadrado',1),
(970037,930014,'Rectángulo',1),
(970038,930014,'Triángulo',0);
UPDATE preguntas SET id_evaluacion=920004,texto_pregunta='Un círculo tiene cuatro vértices.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930015;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970039,930015,'Verdadero',0),
(970040,930015,'Falso',1);
UPDATE preguntas SET id_evaluacion=920004,texto_pregunta='Describe un cuadrado y un triángulo. ¿En qué se diferencian sus cantidades de lados?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930016;
UPDATE preguntas SET id_evaluacion=920005,texto_pregunta='¿Cuántos vértices tiene un rectángulo?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930017;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970041,930017,'5',0),
(970042,930017,'6',0),
(970043,930017,'4',1),
(970044,930017,'3',0);
UPDATE preguntas SET id_evaluacion=920005,texto_pregunta='Marca las afirmaciones verdaderas sobre un cuadrado.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930018;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970045,930018,'No tiene lados rectos',0),
(970046,930018,'Tiene cuatro lados iguales',1),
(970047,930018,'Tiene cuatro vértices',1),
(970048,930018,'Tiene tres lados',0);
UPDATE preguntas SET id_evaluacion=920005,texto_pregunta='Un triángulo sigue teniendo tres lados aunque lo giremos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930019;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970049,930019,'Verdadero',1),
(970050,930019,'Falso',0);
UPDATE preguntas SET id_evaluacion=920005,texto_pregunta='Una pelota está debajo de una mesa y un libro está encima de ella. Describe dónde está cada objeto respecto de la mesa.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930020;
UPDATE preguntas SET id_evaluacion=920006,texto_pregunta='Una figura tiene cuatro lados iguales y cuatro ángulos rectos. ¿Cuál es?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930021;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970051,930021,'Triángulo',0),
(970052,930021,'Pentágono',0),
(970053,930021,'Cuadrado',1),
(970054,930021,'Círculo',0);
UPDATE preguntas SET id_evaluacion=920006,texto_pregunta='Marca las figuras que tienen al menos un lado recto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930022;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970055,930022,'Óvalo',0),
(970056,930022,'Triángulo',1),
(970057,930022,'Rectángulo',1),
(970058,930022,'Círculo',0);
UPDATE preguntas SET id_evaluacion=920006,texto_pregunta='Un rectángulo siempre tiene cinco vértices.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930023;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970059,930023,'Verdadero',0),
(970060,930023,'Falso',1);
UPDATE preguntas SET id_evaluacion=920006,texto_pregunta='Una ventana tiene forma rectangular. Indica cuántos lados y cuántos vértices tiene su contorno.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930024;

-- Lenguaje / Lectura
UPDATE unidades SET id_asignatura=2,id_objetivo=910003,titulo='Lectura',descripcion='Localizar información, ordenar acciones y realizar inferencias a partir de relatos breves.',activo=1 WHERE id_unidad=910003;
UPDATE evaluaciones SET titulo='Exploramos: Lectura',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920007;
UPDATE evaluaciones SET titulo='Aplicamos: Lectura',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920008;
UPDATE evaluaciones SET titulo='Prueba de cierre: Lectura',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920009;
UPDATE preguntas SET id_evaluacion=920007,texto_pregunta='Lee: «Luna encontró una semilla en el patio de la escuela y la sembró en una maceta». ¿Dónde encontró la semilla?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930025;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970061,930025,'En una plaza',0),
(970062,930025,'En el patio de la escuela',1),
(970063,930025,'En la biblioteca',0),
(970064,930025,'En una cocina',0);
UPDATE preguntas SET id_evaluacion=920007,texto_pregunta='Lee: «Luna regaba la semilla. Tomás acercó la maceta a una ventana». Marca las acciones mencionadas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930026;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970065,930026,'Luna regaba la semilla',1),
(970066,930026,'Tomás acercó la maceta a una ventana',1),
(970067,930026,'Luna tiró la maceta',0),
(970068,930026,'Tomás guardó la planta en un cajón',0);
UPDATE preguntas SET id_evaluacion=920007,texto_pregunta='Lee: «Cada mañana, Luna revisaba su maceta». Según el texto, Luna revisaba la maceta por la noche.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930027;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970069,930027,'Falso',1),
(970070,930027,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=920007,texto_pregunta='Lee: «Después de varios días de cuidados, apareció un brote. Luna sonrió». ¿Por qué crees que Luna sonrió? Usa una pista del texto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930028;
UPDATE preguntas SET id_evaluacion=920008,texto_pregunta='Lee: «Mateo tomó su paraguas porque comenzó a llover». ¿Por qué tomó el paraguas?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930029;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970071,930029,'Porque buscaba una pelota',0),
(970072,930029,'Porque comenzó a llover',1),
(970073,930029,'Porque hacía mucho calor',0),
(970074,930029,'Porque iba a leer',0);
UPDATE preguntas SET id_evaluacion=920008,texto_pregunta='Lee: «Eva y Leo ordenaron los cuentos de la biblioteca». Marca los nombres de los personajes.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930030;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970075,930030,'Eva',1),
(970076,930030,'Leo',1),
(970077,930030,'Biblioteca',0),
(970078,930030,'Cuentos',0);
UPDATE preguntas SET id_evaluacion=920008,texto_pregunta='Lee: «Primero Inés lavó una manzana y después la comió». Inés lavó la manzana antes de comerla.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930031;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970079,930031,'Falso',0),
(970080,930031,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920008,texto_pregunta='Lee: «Sara buscó su cuaderno. Lo encontró en la mochila y empezó a escribir». Cuenta las tres acciones en el orden en que ocurrieron.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930032;
UPDATE preguntas SET id_evaluacion=920009,texto_pregunta='Lee: «El huerto estaba seco. Bruno lo regó y al día siguiente la tierra seguía húmeda». ¿Qué hizo Bruno?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930033;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970081,930033,'Cerró la biblioteca',0),
(970082,930033,'Regó el huerto',1),
(970083,930033,'Pintó la tierra',0),
(970084,930033,'Arrancó las plantas',0);
UPDATE preguntas SET id_evaluacion=920009,texto_pregunta='Lee: «En la plaza, Camila jugó con su hermano y luego ambos volvieron a casa». Marca las afirmaciones apoyadas por el texto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930034;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970085,930034,'Camila estaba con su hermano',1),
(970086,930034,'Después volvieron a casa',1),
(970087,930034,'Jugaron en una playa',0),
(970088,930034,'Volvieron a la escuela',0);
UPDATE preguntas SET id_evaluacion=920009,texto_pregunta='Lee: «El gato se escondió al escuchar un ruido fuerte». El texto afirma que el gato se quedó dormido.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930035;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970089,930035,'Falso',1),
(970090,930035,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=920009,texto_pregunta='Lee: «Se apagó la luz. Julia buscó una linterna para seguir leyendo». ¿Para qué buscó la linterna? Explica usando el relato.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930036;

-- Lenguaje / Escritura
UPDATE unidades SET id_asignatura=2,id_objetivo=910004,titulo='Escritura',descripcion='Escribir oraciones claras y revisar mayúsculas, puntuación y orden de las ideas.',activo=1 WHERE id_unidad=910004;
UPDATE evaluaciones SET titulo='Exploramos: Escritura',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920010;
UPDATE evaluaciones SET titulo='Aplicamos: Escritura',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920011;
UPDATE evaluaciones SET titulo='Prueba de cierre: Escritura',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920012;
UPDATE preguntas SET id_evaluacion=920010,texto_pregunta='¿Cuál oración comienza con mayúscula y termina con punto?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930037;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970091,930037,'Ana lee un cuento.',1),
(970092,930037,'ana lee un cuento.',0),
(970093,930037,'Ana lee un cuento',0),
(970094,930037,'ana lee un cuento',0);
UPDATE preguntas SET id_evaluacion=920010,texto_pregunta='Marca las acciones que ayudan a preparar un texto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930038;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970095,930038,'Ordenar las ideas antes de escribir',1),
(970096,930038,'Escribir palabras sin relación',0),
(970097,930038,'Cambiar de tema en cada palabra',0),
(970098,930038,'Pensar qué quiero comunicar',1);
UPDATE preguntas SET id_evaluacion=920010,texto_pregunta='Una oración debe comunicar una idea comprensible.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930039;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970099,930039,'Verdadero',1),
(970100,930039,'Falso',0);
UPDATE preguntas SET id_evaluacion=920010,texto_pregunta='Ordena estas palabras y escribe una oración con mayúscula inicial y punto final: juega / Ana / en el patio.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930040;
UPDATE preguntas SET id_evaluacion=920011,texto_pregunta='¿Qué palabra completa con sentido la oración «El perro bebe ___»?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930041;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970101,930041,'agua',1),
(970102,930041,'sillas',0),
(970103,930041,'cuadernos',0),
(970104,930041,'ventanas',0);
UPDATE preguntas SET id_evaluacion=920011,texto_pregunta='Marca las revisiones que mejoran una oración.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930042;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970105,930042,'Revisar la mayúscula inicial y el punto final',1),
(970106,930042,'Borrar todas las vocales',0),
(970107,930042,'Agregar palabras sin relación',0),
(970108,930042,'Comprobar que las palabras se entiendan',1);
UPDATE preguntas SET id_evaluacion=920011,texto_pregunta='La secuencia «mesa corre azul porque» comunica una idea completa y clara.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930043;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970109,930043,'Verdadero',0),
(970110,930043,'Falso',1);
UPDATE preguntas SET id_evaluacion=920011,texto_pregunta='Escribe dos oraciones que expliquen cómo cuidas tus útiles escolares.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930044;
UPDATE preguntas SET id_evaluacion=920012,texto_pregunta='¿Cuál oración expresa una idea completa sobre un animal?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930045;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970111,930045,'El gato duerme en su cama.',1),
(970112,930045,'El gato en.',0),
(970113,930045,'Duerme su porque.',0),
(970114,930045,'Cama el con.',0);
UPDATE preguntas SET id_evaluacion=920012,texto_pregunta='Marca las palabras que permiten ordenar los pasos de una explicación.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930046;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970115,930046,'Después',1),
(970116,930046,'Ventana',0),
(970117,930046,'Zapato',0),
(970118,930046,'Primero',1);
UPDATE preguntas SET id_evaluacion=920012,texto_pregunta='Releer lo que escribimos ayuda a encontrar palabras que faltan.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930047;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970119,930047,'Verdadero',1),
(970120,930047,'Falso',0);
UPDATE preguntas SET id_evaluacion=920012,texto_pregunta='Escribe una invitación breve a leer en la biblioteca. Indica qué se hará, dónde y cuándo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930048;

-- Historia / Civilizaciones antiguas
UPDATE unidades SET id_asignatura=5,id_objetivo=910005,titulo='Civilizaciones antiguas',descripcion='Relacionar civilizaciones antiguas con sus ríos, actividades y aportes culturales.',activo=1 WHERE id_unidad=910005;
UPDATE evaluaciones SET titulo='Exploramos: Civilizaciones antiguas',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920013;
UPDATE evaluaciones SET titulo='Aplicamos: Civilizaciones antiguas',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920014;
UPDATE evaluaciones SET titulo='Prueba de cierre: Civilizaciones antiguas',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920015;
UPDATE preguntas SET id_evaluacion=920013,texto_pregunta='¿Qué río fue fundamental para la agricultura del antiguo Egipto?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930049;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970121,930049,'Amazonas',0),
(970122,930049,'Biobío',0),
(970123,930049,'Mapocho',0),
(970124,930049,'Nilo',1);
UPDATE preguntas SET id_evaluacion=920013,texto_pregunta='Marca las actividades que realizaban las comunidades del antiguo Egipto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930050;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970125,930050,'Viajar en aviones',0),
(970126,930050,'Usar teléfonos móviles',0),
(970127,930050,'Cultivar junto al río Nilo',1),
(970128,930050,'Construir canales para conducir agua',1);
UPDATE preguntas SET id_evaluacion=920013,texto_pregunta='La agricultura ayudó a que algunas comunidades se establecieran en un lugar.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930051;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970129,930051,'Falso',0),
(970130,930051,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920013,texto_pregunta='Explica una razón por la que vivir cerca de un río podía ayudar a una comunidad antigua.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930052;
UPDATE preguntas SET id_evaluacion=920014,texto_pregunta='Mesopotamia se desarrolló entre dos ríos. ¿Cuáles eran?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930053;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970131,930053,'Nilo y Amazonas',0),
(970132,930053,'Biobío y Loa',0),
(970133,930053,'Sena y Támesis',0),
(970134,930053,'Tigris y Éufrates',1);
UPDATE preguntas SET id_evaluacion=920014,texto_pregunta='Marca las fuentes que provienen directamente de una civilización antigua.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930054;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970135,930054,'Una película de ficción actual',0),
(970136,930054,'Una noticia sobre un viaje espacial actual',0),
(970137,930054,'Restos de construcciones',1),
(970138,930054,'Tablillas con escritura de esa época',1);
UPDATE preguntas SET id_evaluacion=920014,texto_pregunta='Las civilizaciones antiguas usaban electricidad y computadores de la misma manera que nosotros.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930055;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970139,930055,'Falso',1),
(970140,930055,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=920014,texto_pregunta='¿Para qué podía servir la escritura a una comunidad que almacenaba alimentos? Da un ejemplo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930056;
UPDATE preguntas SET id_evaluacion=920015,texto_pregunta='¿Cuál de estos aportes permite dejar registros escritos de acuerdos o cantidades?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930057;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970141,930057,'El avión',0),
(970142,930057,'El teléfono móvil',0),
(970143,930057,'El semáforo eléctrico',0),
(970144,930057,'La escritura',1);
UPDATE preguntas SET id_evaluacion=920015,texto_pregunta='Marca las condiciones que favorecieron el cultivo en comunidades antiguas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930058;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970145,930058,'Ausencia total de agua',0),
(970146,930058,'Imposibilidad de cuidar los cultivos',0),
(970147,930058,'Disponibilidad de agua',1),
(970148,930058,'Tierras adecuadas para sembrar',1);
UPDATE preguntas SET id_evaluacion=920015,texto_pregunta='Un objeto antiguo puede entregar información sobre la vida de quienes lo utilizaron.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930059;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970149,930059,'Falso',0),
(970150,930059,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920015,texto_pregunta='Un grupo encuentra una vasija antigua. Explica qué podría enseñar sobre esa comunidad y por qué no basta con imaginar su uso.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930060;

-- Historia / Exploraciones
UPDATE unidades SET id_asignatura=5,id_objetivo=910006,titulo='Exploraciones',descripcion='Reconocer instrumentos de navegación y describir encuentros entre sociedades durante las exploraciones.',activo=1 WHERE id_unidad=910006;
UPDATE evaluaciones SET titulo='Exploramos: Exploraciones',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920016;
UPDATE evaluaciones SET titulo='Aplicamos: Exploraciones',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920017;
UPDATE evaluaciones SET titulo='Prueba de cierre: Exploraciones',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920018;
UPDATE preguntas SET id_evaluacion=920016,texto_pregunta='¿Qué instrumento ayuda a orientarse al indicar la dirección del norte magnético?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930061;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970151,930061,'Termómetro',0),
(970152,930061,'Reloj de arena',0),
(970153,930061,'Brújula',1),
(970154,930061,'Balanza',0);
UPDATE preguntas SET id_evaluacion=920016,texto_pregunta='Marca elementos útiles para planificar un viaje marítimo de exploración.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930062;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970155,930062,'Salir sin conocer el destino ni preparar el barco',0),
(970156,930062,'Mapas de las costas conocidas',1),
(970157,930062,'Provisiones de agua y alimentos',1),
(970158,930062,'Un itinerario sin considerar distancias',0);
UPDATE preguntas SET id_evaluacion=920016,texto_pregunta='América ya estaba habitada por diversos pueblos antes de la llegada de las expediciones europeas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930063;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970159,930063,'Verdadero',1),
(970160,930063,'Falso',0);
UPDATE preguntas SET id_evaluacion=920016,texto_pregunta='Explica por qué una tripulación necesitaba planificar sus provisiones antes de un viaje largo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930064;
UPDATE preguntas SET id_evaluacion=920017,texto_pregunta='¿Qué océano cruzó la expedición de Cristóbal Colón al viajar desde Europa hasta América en 1492?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930065;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970161,930065,'Ártico',0),
(970162,930065,'Antártico',0),
(970163,930065,'Atlántico',1),
(970164,930065,'Índico',0);
UPDATE preguntas SET id_evaluacion=920017,texto_pregunta='Marca afirmaciones que reconocen la diversidad de los encuentros entre europeos y pueblos americanos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930066;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970165,930066,'Todos los pueblos tenían las mismas costumbres',0),
(970166,930066,'Los pueblos americanos tenían culturas propias',1),
(970167,930066,'Los encuentros produjeron intercambios y también conflictos',1),
(970168,930066,'América estaba deshabitada',0);
UPDATE preguntas SET id_evaluacion=920017,texto_pregunta='Todos los encuentros entre expediciones europeas y pueblos americanos fueron pacíficos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930067;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970169,930067,'Verdadero',0),
(970170,930067,'Falso',1);
UPDATE preguntas SET id_evaluacion=920017,texto_pregunta='¿Por qué es incorrecto decir que los exploradores llegaron a un continente sin habitantes al referirse a América?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930068;
UPDATE preguntas SET id_evaluacion=920018,texto_pregunta='¿Qué documento podía ayudar a una tripulación a reconocer una costa y planificar su ruta?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930069;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970171,930069,'Un catálogo de muebles',0),
(970172,930069,'Una lista de alumnos',0),
(970173,930069,'Un mapa náutico',1),
(970174,930069,'Una receta de cocina',0);
UPDATE preguntas SET id_evaluacion=920018,texto_pregunta='Marca preguntas que ayudan a estudiar un viaje de exploración.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930070;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970175,930070,'¿Qué aeropuerto usó el barco?',0),
(970176,930070,'¿Qué ruta siguió la expedición?',1),
(970177,930070,'¿Con qué pueblos se encontró?',1),
(970178,930070,'¿Cuántos teléfonos móviles llevó en 1492?',0);
UPDATE preguntas SET id_evaluacion=920018,texto_pregunta='Comparar relatos de distintas personas ayuda a comprender un encuentro histórico desde más de una perspectiva.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930071;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970179,930071,'Verdadero',1),
(970180,930071,'Falso',0);
UPDATE preguntas SET id_evaluacion=920018,texto_pregunta='Menciona una utilidad de los mapas y una de la brújula durante un viaje marítimo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930072;

-- Ciencias / Biología
UPDATE unidades SET id_asignatura=3,id_objetivo=910007,titulo='Biología',descripcion='Reconocer seres vivos, sus necesidades y relaciones con el ambiente.',activo=1 WHERE id_unidad=910007;
UPDATE evaluaciones SET titulo='Exploramos: Biología',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920019;
UPDATE evaluaciones SET titulo='Aplicamos: Biología',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920020;
UPDATE evaluaciones SET titulo='Prueba de cierre: Biología',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920021;
UPDATE preguntas SET id_evaluacion=920019,texto_pregunta='¿Cuál de estos elementos es un ser vivo?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930073;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970181,930073,'Una pelota',0),
(970182,930073,'Un árbol',1),
(970183,930073,'Una piedra',0),
(970184,930073,'Una banca',0);
UPDATE preguntas SET id_evaluacion=920019,texto_pregunta='Marca necesidades básicas de un gato.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930074;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970185,930074,'Agua',1),
(970186,930074,'Alimento adecuado',1),
(970187,930074,'Un teléfono',0),
(970188,930074,'Un cuaderno',0);
UPDATE preguntas SET id_evaluacion=920019,texto_pregunta='Las plantas son seres vivos aunque no caminen de un lugar a otro.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930075;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970189,930075,'Falso',0),
(970190,930075,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920019,texto_pregunta='Explica una diferencia entre una planta viva y una planta de plástico.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930076;
UPDATE preguntas SET id_evaluacion=920020,texto_pregunta='Una planta crece en una maceta y su tierra está seca. ¿Qué cuidado necesita?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930077;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970191,930077,'Encerrarla sin luz',0),
(970192,930077,'Riego con una cantidad adecuada de agua',1),
(970193,930077,'Pintar sus hojas',0),
(970194,930077,'Quitarle toda la tierra',0);
UPDATE preguntas SET id_evaluacion=920020,texto_pregunta='Marca relaciones de alimentación entre seres vivos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930078;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970195,930078,'Un conejo come pasto',1),
(970196,930078,'Un zorro come un conejo',1),
(970197,930078,'Una piedra come pasto',0),
(970198,930078,'Una banca alimenta a una nube',0);
UPDATE preguntas SET id_evaluacion=920020,texto_pregunta='Una semilla viable puede germinar si tiene las condiciones adecuadas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930079;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970199,930079,'Falso',0),
(970200,930079,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=920020,texto_pregunta='Describe dos cuidados que necesita una planta y explica para qué sirve uno de ellos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930080;
UPDATE preguntas SET id_evaluacion=920021,texto_pregunta='¿Cuál es un ejemplo de hábitat de un pez de río?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930081;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970201,930081,'Una repisa sin agua',0),
(970202,930081,'Un río con condiciones adecuadas para esa especie',1),
(970203,930081,'Un cajón seco',0),
(970204,930081,'Una carretera',0);
UPDATE preguntas SET id_evaluacion=920021,texto_pregunta='Marca acciones que ayudan a cuidar los seres vivos de un huerto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930082;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970205,930082,'Regar según las necesidades de las plantas',1),
(970206,930082,'Evitar arrojar basura en el huerto',1),
(970207,930082,'Arrancar todas las plantas',0),
(970208,930082,'Dejar residuos sobre los cultivos',0);
UPDATE preguntas SET id_evaluacion=920021,texto_pregunta='Todos los animales comen exactamente el mismo tipo de alimento.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930083;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970209,930083,'Falso',1),
(970210,930083,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=920021,texto_pregunta='¿Qué podría ocurrir con una planta si pasa mucho tiempo sin recibir agua? Explica tu respuesta.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930084;

-- Ciencias / Microscopía
UPDATE unidades SET id_asignatura=3,id_objetivo=910008,titulo='Microscopía',descripcion='Reconocer las funciones del microscopio y describir observaciones de muestras.',activo=1 WHERE id_unidad=910008;
UPDATE evaluaciones SET titulo='Exploramos: Microscopía',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920022;
UPDATE evaluaciones SET titulo='Aplicamos: Microscopía',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=920023;
UPDATE evaluaciones SET titulo='Prueba de cierre: Microscopía',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=920024;
UPDATE preguntas SET id_evaluacion=920022,texto_pregunta='¿Para qué sirve principalmente un microscopio óptico escolar?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930085;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970211,930085,'Observar detalles demasiado pequeños para distinguirlos a simple vista',1),
(970212,930085,'Medir la temperatura del aire',0),
(970213,930085,'Pesar una muestra',0),
(970214,930085,'Orientarse hacia el norte',0);
UPDATE preguntas SET id_evaluacion=920022,texto_pregunta='Marca partes del microscopio relacionadas con el aumento de la imagen.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930086;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970215,930086,'Objetivos',1),
(970216,930086,'Cable de un teléfono',0),
(970217,930086,'Brújula',0),
(970218,930086,'Ocular',1);
UPDATE preguntas SET id_evaluacion=920022,texto_pregunta='Un microscopio óptico permite observar detalles que nuestros ojos solos no distinguen.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930087;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970219,930087,'Verdadero',1),
(970220,930087,'Falso',0);
UPDATE preguntas SET id_evaluacion=920022,texto_pregunta='Describe una diferencia entre observar una hoja a simple vista y observar una muestra de ella con un microscopio.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930088;
UPDATE preguntas SET id_evaluacion=920023,texto_pregunta='¿Cómo se llama la lámina de vidrio donde se coloca una muestra para observarla?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930089;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970221,930089,'Portaobjetos',1),
(970222,930089,'Brújula',0),
(970223,930089,'Balanza',0),
(970224,930089,'Cronómetro',0);
UPDATE preguntas SET id_evaluacion=920023,texto_pregunta='Marca prácticas adecuadas al usar un microscopio escolar.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930090;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970225,930090,'Manipular las muestras y lentes con cuidado',1),
(970226,930090,'Tocar las lentes con los dedos sucios',0),
(970227,930090,'Forzar los tornillos cuando no giran',0),
(970228,930090,'Seguir las indicaciones del docente',1);
UPDATE preguntas SET id_evaluacion=920023,texto_pregunta='Los objetivos del microscopio deben golpearse contra la muestra para enfocar.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930091;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970229,930091,'Verdadero',0),
(970230,930091,'Falso',1);
UPDATE preguntas SET id_evaluacion=920023,texto_pregunta='Una observación muestra pequeñas estructuras en una muestra de cebolla. ¿Por qué conviene dibujarlas y anotar lo observado?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930092;
UPDATE preguntas SET id_evaluacion=920024,texto_pregunta='Un microscopio tiene un ocular de 10 aumentos y un objetivo de 4 aumentos. ¿Cuál es el aumento total?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=930093;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970231,930093,'40 aumentos',1),
(970232,930093,'14 aumentos',0),
(970233,930093,'6 aumentos',0),
(970234,930093,'104 aumentos',0);
UPDATE preguntas SET id_evaluacion=920024,texto_pregunta='Marca datos útiles para registrar una observación al microscopio.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=930094;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970235,930094,'El aumento utilizado',1),
(970236,930094,'Una respuesta inventada antes de observar',0),
(970237,930094,'Una descripción de otra muestra que no se examinó',0),
(970238,930094,'El nombre de la muestra',1);
UPDATE preguntas SET id_evaluacion=920024,texto_pregunta='Una conclusión debe basarse en lo que se observó y no en detalles inventados.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=930095;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970239,930095,'Verdadero',1),
(970240,930095,'Falso',0);
UPDATE preguntas SET id_evaluacion=920024,texto_pregunta='Dos estudiantes observan la misma muestra con aumentos distintos. Menciona un dato que deberían registrar para poder comparar sus observaciones.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=930096;

-- Matemática / Cuerpos geométricos
UPDATE unidades SET id_asignatura=1,id_objetivo=910009,titulo='Cuerpos geométricos',descripcion='Distinguir cuerpos geométricos y describir sus caras, aristas y vértices.',activo=1 WHERE id_unidad=910009;
UPDATE evaluaciones SET titulo='Exploramos: Cuerpos geométricos',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921001;
UPDATE evaluaciones SET titulo='Prueba de cierre: Cuerpos geométricos',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921002;
UPDATE preguntas SET id_evaluacion=921001,texto_pregunta='¿Qué cuerpo geométrico tiene seis caras cuadradas iguales?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931002;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970241,931002,'Esfera',0),
(970242,931002,'Cono',0),
(970243,931002,'Cilindro',0),
(970244,931002,'Cubo',1);
UPDATE preguntas SET id_evaluacion=921001,texto_pregunta='Marca los cuerpos que tienen al menos una base circular plana.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931003;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970245,931003,'Cubo',0),
(970246,931003,'Pirámide de base cuadrada',0),
(970247,931003,'Cilindro',1),
(970248,931003,'Cono',1);
UPDATE preguntas SET id_evaluacion=921001,texto_pregunta='Una esfera tiene una superficie curva y no tiene caras planas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931004;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970249,931004,'Falso',0),
(970250,931004,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921001,texto_pregunta='Una lata cerrada tiene forma de cilindro. Describe sus dos bases y su superficie lateral.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931005;
UPDATE preguntas SET id_evaluacion=921002,texto_pregunta='¿Cuántos vértices tiene un cubo?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931006;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970251,931006,'4',0),
(970252,931006,'6',0),
(970253,931006,'12',0),
(970254,931006,'8',1);
UPDATE preguntas SET id_evaluacion=921002,texto_pregunta='Marca propiedades de una pirámide de base cuadrada.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931007;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970255,931007,'Tiene dos bases circulares',0),
(970256,931007,'Todas sus caras son círculos',0),
(970257,931007,'Tiene una base cuadrada',1),
(970258,931007,'Sus caras laterales son triángulos',1);
UPDATE preguntas SET id_evaluacion=921002,texto_pregunta='Un cubo tiene doce aristas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931008;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970259,931008,'Falso',0),
(970260,931008,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921002,texto_pregunta='Compara un cubo con una esfera. Menciona una diferencia que permita distinguirlos.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931009;

-- Matemática / Estadística
UPDATE unidades SET id_asignatura=1,id_objetivo=910010,titulo='Estadística',descripcion='Organizar e interpretar cantidades en tablas y gráficos sencillos.',activo=1 WHERE id_unidad=910010;
UPDATE evaluaciones SET titulo='Exploramos: Estadística',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921003;
UPDATE evaluaciones SET titulo='Prueba de cierre: Estadística',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921004;
UPDATE preguntas SET id_evaluacion=921003,texto_pregunta='Una encuesta registra 8 votos por lectura, 5 por deporte y 3 por dibujo. ¿Qué actividad recibió más votos?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931010;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970261,931010,'Dibujo',0),
(970262,931010,'Todas recibieron lo mismo',0),
(970263,931010,'Lectura',1),
(970264,931010,'Deporte',0);
UPDATE preguntas SET id_evaluacion=921003,texto_pregunta='En una tabla hay 4 perros, 7 gatos y 2 conejos. Marca las afirmaciones correctas.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931011;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970265,931011,'Hay igual cantidad de perros y gatos',0),
(970266,931011,'Hay más gatos que perros',1),
(970267,931011,'Hay menos conejos que perros',1),
(970268,931011,'Hay más conejos que gatos',0);
UPDATE preguntas SET id_evaluacion=921003,texto_pregunta='Un gráfico de barras puede servir para comparar cantidades de distintas categorías.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931012;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970269,931012,'Verdadero',1),
(970270,931012,'Falso',0);
UPDATE preguntas SET id_evaluacion=921003,texto_pregunta='En una encuesta, 6 estudiantes eligieron manzana y 4 eligieron pera. ¿Cuántos estudiantes respondieron? Explica cómo lo sabes.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931013;
UPDATE preguntas SET id_evaluacion=921004,texto_pregunta='Una tabla muestra 3 votos por rojo, 9 por azul y 5 por verde. ¿Cuál color recibió menos votos?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931014;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970271,931014,'Verde',0),
(970272,931014,'Todos recibieron lo mismo',0),
(970273,931014,'Rojo',1),
(970274,931014,'Azul',0);
UPDATE preguntas SET id_evaluacion=921004,texto_pregunta='Marca elementos que ayudan a entender un gráfico de barras.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931015;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970275,931015,'Categorías sin identificar',0),
(970276,931015,'Un título que indique qué datos representa',1),
(970277,931015,'Nombres de las categorías y una escala numérica',1),
(970278,931015,'Barras sin relación con los datos',0);
UPDATE preguntas SET id_evaluacion=921004,texto_pregunta='Si una barra llega al valor 8 y otra al valor 5 en la misma escala, la primera representa tres unidades más.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931016;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970279,931016,'Verdadero',1),
(970280,931016,'Falso',0);
UPDATE preguntas SET id_evaluacion=921004,texto_pregunta='En una tabla hay 7 votos por fútbol y 3 por básquetbol. ¿Cuántos votos más obtuvo fútbol? Escribe la operación.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931017;

-- Lenguaje / Literatura
UPDATE unidades SET id_asignatura=2,id_objetivo=910011,titulo='Literatura',descripcion='Reconocer personajes, ambientes y recursos de textos literarios breves.',activo=1 WHERE id_unidad=910011;
UPDATE evaluaciones SET titulo='Exploramos: Literatura',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921005;
UPDATE evaluaciones SET titulo='Prueba de cierre: Literatura',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921006;
UPDATE preguntas SET id_evaluacion=921005,texto_pregunta='¿Cómo se llama el personaje que ocupa el lugar central en las acciones principales de un relato?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931018;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970281,931018,'Lector',0),
(970282,931018,'Protagonista',1),
(970283,931018,'Autor',0),
(970284,931018,'Ilustrador',0);
UPDATE preguntas SET id_evaluacion=921005,texto_pregunta='Lee: «La zorra habló con el cuervo para conseguir su queso». Marca los personajes del fragmento.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931019;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970285,931019,'La zorra',1),
(970286,931019,'El cuervo',1),
(970287,931019,'El queso',0),
(970288,931019,'El árbol que no se menciona',0);
UPDATE preguntas SET id_evaluacion=921005,texto_pregunta='Una fábula puede presentar animales que hablan y una enseñanza o moraleja.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931020;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970289,931020,'Falso',0),
(970290,931020,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921005,texto_pregunta='Lee: «El ratón ayudó al león a salir de una red. El león aprendió que incluso alguien pequeño puede ayudar». Explica una enseñanza del relato.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931021;
UPDATE preguntas SET id_evaluacion=921006,texto_pregunta='Lee: «Elena caminó por un bosque oscuro hasta una cabaña». ¿Qué opción describe el ambiente del fragmento?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931022;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970291,931022,'La moraleja de una fábula',0),
(970292,931022,'Un bosque y una cabaña',1),
(970293,931022,'El nombre de la autora',0),
(970294,931022,'La cantidad de páginas',0);
UPDATE preguntas SET id_evaluacion=921006,texto_pregunta='Lee: «Pablo tembló al oír un rugido y se escondió detrás de una roca». Marca pistas de que sentía miedo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931023;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970295,931023,'Tembló al oír el rugido',1),
(970296,931023,'Se escondió detrás de una roca',1),
(970297,931023,'Se puso a cantar alegremente',0),
(970298,931023,'Corrió a abrazar al animal',0);
UPDATE preguntas SET id_evaluacion=921006,texto_pregunta='El autor de un cuento y el narrador de ese cuento son siempre la misma persona.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931024;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970299,931024,'Falso',1),
(970300,931024,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=921006,texto_pregunta='Lee: «La luna era una lámpara sobre el mar». ¿Con qué se compara la luna y qué característica comparten en esta expresión?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931025;

-- Lenguaje / Comunicación
UPDATE unidades SET id_asignatura=2,id_objetivo=910012,titulo='Comunicación',descripcion='Comunicar ideas con claridad y adaptar el mensaje a su propósito y destinatario.',activo=1 WHERE id_unidad=910012;
UPDATE evaluaciones SET titulo='Exploramos: Comunicación',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921007;
UPDATE evaluaciones SET titulo='Prueba de cierre: Comunicación',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921008;
UPDATE preguntas SET id_evaluacion=921007,texto_pregunta='¿Qué conviene hacer antes de exponer un tema frente al curso?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931026;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970301,931026,'Preparar y ordenar las ideas principales',1),
(970302,931026,'Inventar todos los datos al comenzar',0),
(970303,931026,'Evitar conocer el tema',0),
(970304,931026,'Memorizar palabras sin comprenderlas',0);
UPDATE preguntas SET id_evaluacion=921007,texto_pregunta='Marca acciones de escucha activa durante una conversación.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931027;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970305,931027,'Hacer una pregunta relacionada con lo escuchado',1),
(970306,931027,'Interrumpir constantemente',0),
(970307,931027,'Cambiar de tema sin escuchar',0),
(970308,931027,'Prestar atención a quien habla',1);
UPDATE preguntas SET id_evaluacion=921007,texto_pregunta='El destinatario es la persona o el grupo al que dirigimos un mensaje.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931028;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970309,931028,'Verdadero',1),
(970310,931028,'Falso',0);
UPDATE preguntas SET id_evaluacion=921007,texto_pregunta='Escribe un mensaje breve para pedir a tu profesora un libro de la biblioteca. Usa un saludo y expresa con claridad tu petición.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931029;
UPDATE preguntas SET id_evaluacion=921008,texto_pregunta='¿Qué saludo es adecuado para comenzar una carta formal a la directora de una escuela?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931030;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970311,931030,'Estimada directora:',1),
(970312,931030,'Oye, tú:',0),
(970313,931030,'Chao, nos vemos:',0),
(970314,931030,'¡Qué lata escribir!',0);
UPDATE preguntas SET id_evaluacion=921008,texto_pregunta='Marca datos necesarios en un aviso que invita a una reunión.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931031;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970315,931031,'El día y la hora de la reunión',1),
(970316,931031,'Un lugar secreto que nadie conoce',0),
(970317,931031,'Una fecha distinta a la reunión',0),
(970318,931031,'El lugar de la reunión',1);
UPDATE preguntas SET id_evaluacion=921008,texto_pregunta='Hablar con claridad significa decir todas las palabras lo más rápido posible.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931032;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970319,931032,'Verdadero',0),
(970320,931032,'Falso',1);
UPDATE preguntas SET id_evaluacion=921008,texto_pregunta='Un compañero no entendió tu explicación de un juego. Describe una acción que podrías hacer para ayudarlo a comprender.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931033;

-- Ciencias / Química
UPDATE unidades SET id_asignatura=3,id_objetivo=910013,titulo='Química',descripcion='Distinguir propiedades de materiales, mezclas y cambios de estado cotidianos.',activo=1 WHERE id_unidad=910013;
UPDATE evaluaciones SET titulo='Exploramos: Química',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921009;
UPDATE evaluaciones SET titulo='Prueba de cierre: Química',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921010;
UPDATE preguntas SET id_evaluacion=921009,texto_pregunta='Un charco se seca lentamente porque parte del agua pasa al aire como vapor. ¿Cómo se llama ese cambio?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931034;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970321,931034,'Congelación',0),
(970322,931034,'Fusión',0),
(970323,931034,'Condensación',0),
(970324,931034,'Evaporación',1);
UPDATE preguntas SET id_evaluacion=921009,texto_pregunta='Marca propiedades observables de un material.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931035;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970325,931035,'Nombre de su dueño',0),
(970326,931035,'Día de cumpleaños de quien lo usa',0),
(970327,931035,'Color',1),
(970328,931035,'Textura',1);
UPDATE preguntas SET id_evaluacion=921009,texto_pregunta='La masa de un objeto puede medirse usando una balanza.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931036;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970329,931036,'Falso',0),
(970330,931036,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921009,texto_pregunta='Se agrega una pequeña cantidad de sal a un vaso de agua y se revuelve hasta que ya no se distinguen los granos. ¿La sal dejó de existir? Explica.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931037;
UPDATE preguntas SET id_evaluacion=921010,texto_pregunta='El agua líquida se transforma en hielo al enfriarse lo suficiente. ¿Qué cambio ocurre?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931038;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970331,931038,'Evaporación',0),
(970332,931038,'Fusión',0),
(970333,931038,'Condensación',0),
(970334,931038,'Congelación',1);
UPDATE preguntas SET id_evaluacion=921010,texto_pregunta='Marca mezclas formadas por más de un material.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931039;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970335,931039,'Una pieza de cobre puro',0),
(970336,931039,'Un vaso que contiene solo agua destilada',0),
(970337,931039,'Agua con sal disuelta',1),
(970338,931039,'Agua con arena',1);
UPDATE preguntas SET id_evaluacion=921010,texto_pregunta='Cuando un cubo de hielo se derrite, el agua pasa de sólido a líquido.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931040;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970339,931040,'Falso',0),
(970340,931040,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921010,texto_pregunta='Explica una diferencia entre el hielo y el agua líquida al colocarlos en recipientes de distinta forma.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931041;

-- Ciencias / Física
UPDATE unidades SET id_asignatura=3,id_objetivo=910014,titulo='Física',descripcion='Reconocer fuerzas, cambios en el movimiento y formas de energía del entorno.',activo=1 WHERE id_unidad=910014;
UPDATE evaluaciones SET titulo='Exploramos: Física',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921011;
UPDATE evaluaciones SET titulo='Prueba de cierre: Física',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921012;
UPDATE preguntas SET id_evaluacion=921011,texto_pregunta='¿Qué fuerza hace que una pelota soltada cerca de la superficie terrestre caiga hacia el suelo?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931042;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970341,931042,'Fuerza del sonido',0),
(970342,931042,'Fuerza de una sombra',0),
(970343,931042,'Gravedad',1),
(970344,931042,'Fuerza de un imán sobre todo material',0);
UPDATE preguntas SET id_evaluacion=921011,texto_pregunta='Marca efectos que puede producir una fuerza sobre un objeto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931043;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970345,931043,'Hacer desaparecer siempre su masa',0),
(970346,931043,'Cambiar su movimiento',1),
(970347,931043,'Deformarlo',1),
(970348,931043,'Convertirlo siempre en un ser vivo',0);
UPDATE preguntas SET id_evaluacion=921011,texto_pregunta='Un empujón puede poner en movimiento un carrito que estaba detenido.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931044;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970349,931044,'Verdadero',1),
(970350,931044,'Falso',0);
UPDATE preguntas SET id_evaluacion=921011,texto_pregunta='Una pelota en movimiento choca con una pared y cambia de dirección. Explica qué relación tiene ese cambio con una fuerza.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931045;
UPDATE preguntas SET id_evaluacion=921012,texto_pregunta='¿Qué instrumento es adecuado para medir cuánto dura una carrera?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931046;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970351,931046,'Brújula',0),
(970352,931046,'Regla sin reloj',0),
(970353,931046,'Cronómetro',1),
(970354,931046,'Balanza',0);
UPDATE preguntas SET id_evaluacion=921012,texto_pregunta='Marca formas de energía que recibimos del Sol.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931047;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970355,931047,'Electricidad transportada directamente por cables desde el Sol',0),
(970356,931047,'Luz',1),
(970357,931047,'Energía térmica',1),
(970358,931047,'Combustible ya envasado',0);
UPDATE preguntas SET id_evaluacion=921012,texto_pregunta='El roce entre una bicicleta y el suelo puede ayudar a disminuir su movimiento.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931048;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970359,931048,'Verdadero',1),
(970360,931048,'Falso',0);
UPDATE preguntas SET id_evaluacion=921012,texto_pregunta='Describe una situación cotidiana en la que una fuerza cambie la forma de un objeto.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931049;

-- Historia / Roma antigua
UPDATE unidades SET id_asignatura=5,id_objetivo=910015,titulo='Roma antigua',descripcion='Reconocer construcciones, espacios y legados culturales de la antigua Roma.',activo=1 WHERE id_unidad=910015;
UPDATE evaluaciones SET titulo='Exploramos: Roma antigua',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921013;
UPDATE evaluaciones SET titulo='Prueba de cierre: Roma antigua',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921014;
UPDATE preguntas SET id_evaluacion=921013,texto_pregunta='¿Qué ciudad dio su nombre a la civilización romana?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931050;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970361,931050,'Cartago',0),
(970362,931050,'Roma',1),
(970363,931050,'Atenas',0),
(970364,931050,'Alejandría',0);
UPDATE preguntas SET id_evaluacion=921013,texto_pregunta='Marca obras construidas por los romanos para conectar o abastecer sus ciudades.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931051;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970365,931051,'Calzadas',1),
(970366,931051,'Acueductos',1),
(970367,931051,'Aeropuertos',0),
(970368,931051,'Líneas de metro eléctrico',0);
UPDATE preguntas SET id_evaluacion=921013,texto_pregunta='El latín fue una lengua utilizada en la antigua Roma.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931052;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970369,931052,'Falso',0),
(970370,931052,'Verdadero',1);
UPDATE preguntas SET id_evaluacion=921013,texto_pregunta='Explica para qué servía un acueducto romano y por qué era útil para una ciudad.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931053;
UPDATE preguntas SET id_evaluacion=921014,texto_pregunta='¿Cómo se llamaba el espacio público central de muchas ciudades romanas donde se desarrollaban actividades políticas y comerciales?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931054;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970371,931054,'Estación de tren',0),
(970372,931054,'Foro',1),
(970373,931054,'Aeropuerto',0),
(970374,931054,'Estadio de fútbol moderno',0);
UPDATE preguntas SET id_evaluacion=921014,texto_pregunta='Marca legados romanos que se pueden estudiar en la actualidad.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931055;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970375,931055,'Restos de caminos y construcciones',1),
(970376,931055,'La influencia del latín en el español',1),
(970377,931055,'La invención romana del teléfono móvil',0),
(970378,931055,'La construcción romana de aviones de pasajeros',0);
UPDATE preguntas SET id_evaluacion=921014,texto_pregunta='Todas las personas de la antigua Roma tenían los mismos derechos y condiciones de vida.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931056;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970379,931056,'Falso',1),
(970380,931056,'Verdadero',0);
UPDATE preguntas SET id_evaluacion=921014,texto_pregunta='Menciona una diferencia entre una ciudad romana antigua y una ciudad actual, sin afirmar que todos sus habitantes vivían igual.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931057;

-- Historia / Cartografía
UPDATE unidades SET id_asignatura=5,id_objetivo=910016,titulo='Cartografía',descripcion='Interpretar mapas mediante orientación, símbolos, leyendas y escalas sencillas.',activo=1 WHERE id_unidad=910016;
UPDATE evaluaciones SET titulo='Exploramos: Cartografía',estado_activo=1,cantidad_intentos=3 WHERE id_evaluacion=921015;
UPDATE evaluaciones SET titulo='Prueba de cierre: Cartografía',estado_activo=1,cantidad_intentos=2 WHERE id_evaluacion=921016;
UPDATE preguntas SET id_evaluacion=921015,texto_pregunta='¿Para qué sirve la leyenda de un mapa?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931058;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970381,931058,'Explicar el significado de sus símbolos',1),
(970382,931058,'Indicar siempre la temperatura',0),
(970383,931058,'Cambiar la forma del territorio',0),
(970384,931058,'Contar una historia inventada',0);
UPDATE preguntas SET id_evaluacion=921015,texto_pregunta='Marca puntos cardinales.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931059;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970385,931059,'Sur',1),
(970386,931059,'Arriba de la mesa',0),
(970387,931059,'Cerca de la puerta',0),
(970388,931059,'Norte',1);
UPDATE preguntas SET id_evaluacion=921015,texto_pregunta='Si el mapa indica que el norte está arriba, el sur queda abajo.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931060;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970389,931060,'Verdadero',1),
(970390,931060,'Falso',0);
UPDATE preguntas SET id_evaluacion=921015,texto_pregunta='En un mapa, un dibujo de un libro representa una biblioteca. ¿Cómo puedes saber ese significado sin adivinar?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931061;
UPDATE preguntas SET id_evaluacion=921016,texto_pregunta='En un mapa, cada centímetro representa un kilómetro. Dos lugares están separados por 3 centímetros. ¿Qué distancia representan?',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_UNICA'),puntaje_maximo=1 WHERE id_pregunta=931062;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970391,931062,'3 kilómetros',1),
(970392,931062,'1 kilómetro',0),
(970393,931062,'30 kilómetros',0),
(970394,931062,'3 metros',0);
UPDATE preguntas SET id_evaluacion=921016,texto_pregunta='Marca información que puede aparecer en un mapa de una localidad.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='SELECCION_MULTIPLE'),puntaje_maximo=1 WHERE id_pregunta=931063;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970395,931063,'Símbolos de servicios como una biblioteca',1),
(970396,931063,'Todas las conversaciones de sus habitantes',0),
(970397,931063,'Los pensamientos de cada persona',0),
(970398,931063,'Ubicación de calles y plazas',1);
UPDATE preguntas SET id_evaluacion=921016,texto_pregunta='La escala permite relacionar una distancia del mapa con una distancia real.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='VERDADERO_FALSO'),puntaje_maximo=1 WHERE id_pregunta=931064;
INSERT INTO opciones (id_opcion,id_pregunta,texto_alternativa,es_correcta) VALUES
(970399,931064,'Verdadero',1),
(970400,931064,'Falso',0);
UPDATE preguntas SET id_evaluacion=921016,texto_pregunta='Un mapa tiene una flecha que señala el norte hacia la parte superior. ¿Hacia qué lado del mapa queda el este? Explica cómo te orientaste.',id_tipo_pregunta=(SELECT id_tipo_pregunta FROM tipos_pregunta WHERE codigo='DESARROLLO'),puntaje_maximo=2 WHERE id_pregunta=931065;
