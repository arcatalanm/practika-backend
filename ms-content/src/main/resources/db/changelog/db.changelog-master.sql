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

--changeset practika:content-034-multimedia-demo context:@dev
INSERT INTO `actividades` (`id_unidad`, `titulo`, `estado_activo`, `cantidad_intentos`)
SELECT `id_unidad`, 'Demo: imágenes y problemas', 1, 2 FROM `unidades` ORDER BY `id_unidad` LIMIT 1;
SET @demo_actividad = (SELECT `id_actividad` FROM `actividades` WHERE `titulo` = 'Demo: imágenes y problemas' ORDER BY `id_actividad` DESC LIMIT 1);
INSERT INTO `preguntas` (`id_actividad`, `texto_pregunta`, `id_tipo_pregunta`, `puntaje_maximo`)
SELECT @demo_actividad, '¿Qué animal ves?', `id_tipo_pregunta`, 1 FROM `tipos_pregunta`
WHERE `codigo` = 'SELECCION_UNICA' AND @demo_actividad IS NOT NULL;
SET @demo_imagen = (SELECT MAX(`id_pregunta`) FROM `preguntas` WHERE `id_actividad` = @demo_actividad);
INSERT INTO `materiales` (`id_pregunta`, `id_tipo_material`, `titulo`, `contenido_url`, `activo`)
SELECT @demo_imagen, `id_tipo_material`, 'Observa el animal', 'demo-assets/raton.svg', 1
FROM `tipos_material` WHERE `codigo` = 'IMAGEN' AND @demo_imagen IS NOT NULL;
INSERT INTO `opciones` (`id_pregunta`, `texto_alternativa`, `es_correcta`)
SELECT @demo_imagen, 'Ratón', 1 WHERE @demo_imagen IS NOT NULL UNION ALL
SELECT @demo_imagen, 'Gato', 0 WHERE @demo_imagen IS NOT NULL UNION ALL
SELECT @demo_imagen, 'Perro', 0 WHERE @demo_imagen IS NOT NULL;
INSERT INTO `preguntas` (`id_actividad`, `texto_pregunta`, `id_tipo_pregunta`, `puntaje_maximo`)
SELECT @demo_actividad, '¿Cuántas manzanas le quedan a Pedrito?', `id_tipo_pregunta`, 1
FROM `tipos_pregunta` WHERE `codigo` = 'SELECCION_UNICA' AND @demo_actividad IS NOT NULL;
SET @demo_texto = (SELECT MAX(`id_pregunta`) FROM `preguntas` WHERE `id_actividad` = @demo_actividad);
INSERT INTO `materiales` (`id_pregunta`, `id_tipo_material`, `titulo`, `contenido_texto`, `activo`)
SELECT @demo_texto, `id_tipo_material`, 'Lee esta historia',
'Pedrito tenía 45 manzanas en su canasto. Un ladrón le quitó 20 manzanas. Pedrito contó las que le quedaron.', 1
FROM `tipos_material` WHERE `codigo` = 'TEXTO' AND @demo_texto IS NOT NULL;
INSERT INTO `materiales` (`id_pregunta`, `id_tipo_material`, `titulo`, `contenido_url`, `activo`)
SELECT @demo_texto, `id_tipo_material`, 'El canasto de Pedrito', 'demo-assets/manzanas.svg', 1
FROM `tipos_material` WHERE `codigo` = 'IMAGEN' AND @demo_texto IS NOT NULL;
INSERT INTO `opciones` (`id_pregunta`, `texto_alternativa`, `es_correcta`)
SELECT @demo_texto, '25 manzanas', 1 WHERE @demo_texto IS NOT NULL UNION ALL
SELECT @demo_texto, '20 manzanas', 0 WHERE @demo_texto IS NOT NULL UNION ALL
SELECT @demo_texto, '30 manzanas', 0 WHERE @demo_texto IS NOT NULL UNION ALL
SELECT @demo_texto, '65 manzanas', 0 WHERE @demo_texto IS NOT NULL;

--changeset practika:content-035-visual-fractions-demo context:@dev
SET @visual_actividad = (SELECT `id_actividad` FROM `actividades` WHERE `titulo` = 'Representamos fracciones' ORDER BY `id_actividad` LIMIT 1);
SET @visual_p1 = (SELECT `id_pregunta` FROM `preguntas` WHERE `id_actividad` = @visual_actividad ORDER BY `id_pregunta` LIMIT 1 OFFSET 0);
SET @visual_p2 = (SELECT `id_pregunta` FROM `preguntas` WHERE `id_actividad` = @visual_actividad ORDER BY `id_pregunta` LIMIT 1 OFFSET 1);
SET @visual_p3 = (SELECT `id_pregunta` FROM `preguntas` WHERE `id_actividad` = @visual_actividad ORDER BY `id_pregunta` LIMIT 1 OFFSET 2);
SET @visual_p4 = (SELECT `id_pregunta` FROM `preguntas` WHERE `id_actividad` = @visual_actividad ORDER BY `id_pregunta` LIMIT 1 OFFSET 3);
INSERT INTO `materiales` (`id_pregunta`,`id_tipo_material`,`titulo`,`contenido_url`,`activo`)
SELECT @visual_p1,`id_tipo_material`,'Imagen de ejemplo','demo-assets/raton.svg',1
FROM `tipos_material` WHERE `codigo`='IMAGEN' AND @visual_p1 IS NOT NULL;
INSERT INTO `materiales` (`id_pregunta`,`id_tipo_material`,`titulo`,`contenido_texto`,`activo`)
SELECT @visual_p2,`id_tipo_material`,'Texto de ejemplo: el canasto de Pedrito',
'Pedrito tenía 45 manzanas. Un ladrón le quitó 20. ¿Cuántas manzanas le quedaron? Este texto es un recurso de demostración visual.',1
FROM `tipos_material` WHERE `codigo`='TEXTO' AND @visual_p2 IS NOT NULL;
INSERT INTO `materiales` (`id_pregunta`,`id_tipo_material`,`titulo`,`contenido_url`,`activo`)
SELECT @visual_p3,`id_tipo_material`,'GIF de ejemplo: la Tierra gira','demo-assets/tierra.gif',1
FROM `tipos_material` WHERE `codigo`='GIF' AND @visual_p3 IS NOT NULL;
INSERT INTO `materiales` (`id_pregunta`,`id_tipo_material`,`titulo`,`contenido_url`,`activo`)
SELECT @visual_p4,`id_tipo_material`,'Video de ejemplo: flores','demo-assets/flores.mp4',1
FROM `tipos_material` WHERE `codigo`='VIDEO' AND @visual_p4 IS NOT NULL;

--changeset practika:content-036-retire-unit-materials
-- Archive the retired unit-only resources; retain all question and activity resources.
CREATE TABLE `materiales_unidad_archivados` AS SELECT * FROM `materiales`
WHERE `id_unidad` IS NOT NULL AND `id_pregunta` IS NULL AND `id_actividad` IS NULL;
DELETE FROM `materiales` WHERE `id_unidad` IS NOT NULL AND `id_pregunta` IS NULL AND `id_actividad` IS NULL;
ALTER TABLE `materiales` DROP FOREIGN KEY `fk_materiales_unidades`, DROP COLUMN `id_unidad`;

--changeset practika:content-037-serve-resources-from-content
UPDATE `materiales` SET `contenido_url` = CONCAT('/api/v1/content/recursos/', SUBSTRING(`contenido_url`, 13))
WHERE `contenido_url` LIKE 'demo-assets/%';

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
