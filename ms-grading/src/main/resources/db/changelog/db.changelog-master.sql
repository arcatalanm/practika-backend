--liquibase formatted sql


--changeset practika:grading-001-respuestas
CREATE TABLE IF NOT EXISTS `respuestas` (
  `id_respuesta` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_respuestas` PRIMARY KEY (`id_respuesta`),
  `run_estudiante` INT NOT NULL,
  `id_pregunta` INT NOT NULL,
  `numero_intento` INT DEFAULT 1 NOT NULL,
  `fecha_entrega` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `texto_desarrollo` TEXT,
  `puntaje_obtenido` DECIMAL(5,2),
  `estado_revision` VARCHAR(20) DEFAULT 'PENDIENTE' NOT NULL
);

ALTER TABLE `respuestas` ADD CONSTRAINT `uq_respuestas_run_pregunta_intento` UNIQUE (`run_estudiante`, `id_pregunta`, `numero_intento`);

--changeset practika:grading-002-respuestas-opciones
CREATE TABLE IF NOT EXISTS `respuestas_opciones` (
  `id_respuesta` INT NOT NULL,
  `id_opcion` INT NOT NULL
);

ALTER TABLE `respuestas_opciones` ADD CONSTRAINT `pk_respuestas_opciones` PRIMARY KEY (`id_respuesta`, `id_opcion`);

ALTER TABLE `respuestas_opciones` ADD CONSTRAINT `fk_respuestas_opciones_respuestas` FOREIGN KEY (`id_respuesta`) REFERENCES `respuestas` (`id_respuesta`) ON DELETE CASCADE;

--changeset practika:grading-003-observaciones
CREATE TABLE IF NOT EXISTS `observacion_pedagogicas` (
  `id_observacion` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_observacion_pedagogicas` PRIMARY KEY (`id_observacion`),
  `id_actividad` INT,
  `run` INT NOT NULL,
  `texto_retroalimentacion` TEXT NOT NULL,
  `porcentaje_logro` DECIMAL(5,2) NOT NULL
);

--changeset practika:grading-100-dev-data context:@dev
INSERT INTO respuestas (id_respuesta,run_estudiante,id_pregunta,numero_intento,fecha_entrega,texto_desarrollo,puntaje_obtenido,estado_revision) VALUES
            (1,12345670,1,1,'2026-10-20 10:00:00','Elegí la representación que corresponde.',1.00,'REVISADA'),
            (2,12345670,49,1,'2026-10-20 10:05:00','',NULL,'PENDIENTE'),
            (3,12345672,5,1,'2026-10-20 10:10:00','Comparé ambas fracciones usando un denominador común.',0.75,'REVISADA'),
            (4,12345672,50,1,'2026-10-20 10:15:00','',NULL,'PENDIENTE'),
            (5,12345673,17,1,'2026-10-20 10:20:00','',1.00,'REVISADA'),
            (6,12345673,65,1,'2026-10-20 10:25:00','',NULL,'PENDIENTE'),
            (7,12345674,21,1,'2026-10-20 10:30:00','El personaje cambia después del conflicto.',0.50,'REVISADA'),
            (8,12345674,66,1,'2026-10-20 10:35:00','',NULL,'PENDIENTE'),
            (9,12345675,33,1,'2026-10-20 10:40:00','',1.00,'REVISADA'),
            (10,12345675,81,1,'2026-10-20 10:45:00','',NULL,'PENDIENTE'),
            (11,12345676,37,1,'2026-10-20 10:50:00','',0.75,'REVISADA'),
            (12,12345676,82,1,'2026-10-20 10:55:00','',NULL,'PENDIENTE'),
            (13,12345677,41,1,'2026-10-20 11:00:00','',1.00,'REVISADA'),
            (14,12345677,89,1,'2026-10-20 11:05:00','',NULL,'PENDIENTE'),
            (15,12345680,45,1,'2026-10-20 11:10:00','',0.50,'REVISADA'),
            (16,12345680,90,1,'2026-10-20 11:15:00','',NULL,'PENDIENTE');

INSERT INTO respuestas_opciones (id_respuesta,id_opcion)
            SELECT id_respuesta,((id_pregunta - 1) * 4) + 1 FROM respuestas WHERE id_respuesta BETWEEN 1 AND 16;

INSERT INTO observacion_pedagogicas (id_observacion,id_actividad,run,texto_retroalimentacion,porcentaje_logro) VALUES
            (1,1,12345670,'Representa correctamente la fracción y explica su estrategia.',100.00),
            (2,2,12345672,'Revisar la búsqueda de denominadores equivalentes.',75.00),
            (3,5,12345673,'Identifica los elementos principales de la narración.',100.00),
            (4,6,12345674,'Puede justificar mejor la secuencia de acontecimientos.',50.00),
            (5,9,12345675,'Relaciona cada sistema con su función.',100.00),
            (6,10,12345676,'Buen avance; reforzar la explicación de hábitos saludables.',75.00),
            (7,11,12345677,'Distingue los estados de la materia con ejemplos.',100.00),
            (8,12,12345680,'Explicar con más detalle los cambios observados.',50.00);

--changeset practika:grading-004-normalized-review-state
CREATE TABLE `estados_revision` (
  `id_estado_revision` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(20) NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  CONSTRAINT `pk_estados_revision` PRIMARY KEY (`id_estado_revision`),
  CONSTRAINT `uq_estados_revision_codigo` UNIQUE (`codigo`)
);

INSERT INTO `estados_revision` (`codigo`, `nombre`)
SELECT DISTINCT `estado_revision`, CASE `estado_revision`
  WHEN 'PENDIENTE' THEN 'Pendiente' WHEN 'REVISADA' THEN 'Revisada'
  ELSE `estado_revision` END
FROM `respuestas`;
INSERT IGNORE INTO `estados_revision` (`codigo`, `nombre`) VALUES
('PENDIENTE', 'Pendiente'), ('REVISADA', 'Revisada');

ALTER TABLE `respuestas` ADD COLUMN `id_estado_revision` INT NULL;
UPDATE `respuestas` r JOIN `estados_revision` e ON e.`codigo` = r.`estado_revision`
SET r.`id_estado_revision` = e.`id_estado_revision`;
ALTER TABLE `respuestas` MODIFY `id_estado_revision` INT NOT NULL;
ALTER TABLE `respuestas` ADD CONSTRAINT `fk_respuestas_estados_revision`
  FOREIGN KEY (`id_estado_revision`) REFERENCES `estados_revision` (`id_estado_revision`);
ALTER TABLE `respuestas` DROP COLUMN `estado_revision`;

--changeset practika:grading-005-student-content-observations
ALTER TABLE `observacion_pedagogicas` CHANGE COLUMN `run` `run_estudiante` INT NOT NULL;
ALTER TABLE `observacion_pedagogicas` ADD COLUMN `id_prueba` INT NULL;
ALTER TABLE `observacion_pedagogicas` ADD COLUMN `id_curso_portal` INT NULL;

--changeset practika:grading-006-complete-submissions
CREATE TABLE `entregas` (
  `id_entrega` INT AUTO_INCREMENT PRIMARY KEY,
  `run_estudiante` INT NOT NULL,
  `id_actividad` INT NULL,
  `id_prueba` INT NULL,
  `numero_intento` INT NOT NULL,
  `fecha_entrega` DATETIME NOT NULL,
  CONSTRAINT `chk_entrega_destino` CHECK ((`id_actividad` IS NOT NULL) <> (`id_prueba` IS NOT NULL)),
  CONSTRAINT `chk_entrega_intento` CHECK (`numero_intento` >= 1),
  CONSTRAINT `uq_entrega_actividad_intento` UNIQUE (`run_estudiante`, `id_actividad`, `numero_intento`),
  CONSTRAINT `uq_entrega_prueba_intento` UNIQUE (`run_estudiante`, `id_prueba`, `numero_intento`)
);
ALTER TABLE `respuestas` ADD COLUMN `id_entrega` INT NULL,
  ADD CONSTRAINT `fk_respuestas_entregas` FOREIGN KEY (`id_entrega`) REFERENCES `entregas` (`id_entrega`);

--changeset practika:grading-007-submission-review-lifecycle
ALTER TABLE `entregas`
  ADD COLUMN `estado` VARCHAR(20) NOT NULL DEFAULT 'EN_REVISION',
  ADD COLUMN `permite_reintento` BOOLEAN NOT NULL DEFAULT 0,
  ADD COLUMN `fecha_revision` DATETIME NULL,
  ADD COLUMN `comentario` TEXT NULL,
  ADD CONSTRAINT `chk_entrega_estado` CHECK (`estado` IN ('EN_REVISION', 'FINALIZADO'));
UPDATE `entregas` e SET e.`estado` = 'FINALIZADO', e.`fecha_revision` = CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM `respuestas` r WHERE r.`id_entrega` = e.`id_entrega`)
AND NOT EXISTS (SELECT 1 FROM `respuestas` r JOIN `estados_revision` er ON er.`id_estado_revision` = r.`id_estado_revision`
  WHERE r.`id_entrega` = e.`id_entrega` AND (er.`codigo` <> 'REVISADA' OR r.`puntaje_obtenido` IS NULL));

--changeset practika:grading-008-course-context-and-frozen-content
ALTER TABLE `entregas`
  ADD COLUMN `id_evaluacion_asignada` INT NULL,
  ADD COLUMN `id_curso_portal` INT NULL,
  ADD COLUMN `id_periodo_academico` INT NULL,
  ADD COLUMN `id_seccion` INT NULL,
  ADD COLUMN `snapshot_evaluacion` LONGTEXT NULL,
  ADD COLUMN `snapshot_reconstruido` BOOLEAN NOT NULL DEFAULT 0,
  DROP INDEX `uq_entrega_actividad_intento`,
  DROP INDEX `uq_entrega_prueba_intento`,
  ADD CONSTRAINT `uq_entrega_evaluacion_intento` UNIQUE (`run_estudiante`,`id_evaluacion_asignada`,`numero_intento`),
  ADD CONSTRAINT `chk_entrega_contexto` CHECK (
    (`id_evaluacion_asignada` IS NULL AND `id_curso_portal` IS NULL AND `id_periodo_academico` IS NULL AND `id_seccion` IS NULL AND `snapshot_evaluacion` IS NULL) OR
    (`id_evaluacion_asignada` IS NOT NULL AND `id_curso_portal` IS NOT NULL AND `id_periodo_academico` IS NOT NULL AND `id_seccion` IS NOT NULL AND `snapshot_evaluacion` IS NOT NULL));
ALTER TABLE `respuestas` DROP INDEX `uq_respuestas_run_pregunta_intento`,
  ADD CONSTRAINT `uq_respuesta_entrega_pregunta` UNIQUE (`id_entrega`,`id_pregunta`);
CREATE INDEX `ix_entregas_curso_fecha` ON `entregas` (`id_curso_portal`,`fecha_entrega`);

--changeset practika:grading-009-local-invariants
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM observacion_pedagogicas WHERE (id_actividad IS NULL) = (id_prueba IS NULL) OR porcentaje_logro NOT BETWEEN 0 AND 100
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM respuestas WHERE numero_intento < 1 OR puntaje_obtenido < 0
ALTER TABLE `observacion_pedagogicas`
  ADD CONSTRAINT `chk_observacion_destino` CHECK ((`id_actividad` IS NOT NULL) <> (`id_prueba` IS NOT NULL)),
  ADD CONSTRAINT `chk_observacion_porcentaje` CHECK (`porcentaje_logro` BETWEEN 0 AND 100);
ALTER TABLE `respuestas` ADD CONSTRAINT `chk_respuesta_intento` CHECK (`numero_intento` >= 1),
  ADD CONSTRAINT `chk_respuesta_puntaje` CHECK (`puntaje_obtenido` IS NULL OR `puntaje_obtenido` >= 0);

--changeset practika:grading-010-section-without-school-year
ALTER TABLE entregas DROP CHECK chk_entrega_contexto;
ALTER TABLE entregas ADD CONSTRAINT chk_entrega_contexto CHECK (
  (id_evaluacion_asignada IS NULL AND id_curso_portal IS NULL AND id_periodo_academico IS NULL AND id_seccion IS NULL AND snapshot_evaluacion IS NULL) OR
  (id_evaluacion_asignada IS NOT NULL AND id_curso_portal IS NOT NULL AND id_seccion IS NOT NULL AND snapshot_evaluacion IS NOT NULL));
