--liquibase formatted sql


--changeset practika:auth-001-cursos
CREATE TABLE IF NOT EXISTS `cursos` (
  `id_curso` INT AUTO_INCREMENT NOT NULL,
  CONSTRAINT `pk_cursos` PRIMARY KEY (`id_curso`),
  `nivel_educativo` VARCHAR(50) NOT NULL,
  `letra_curso` CHAR(1) NOT NULL,
  `activo` BOOLEAN DEFAULT 1 NOT NULL
);

--changeset practika:auth-002-usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `run` INT NOT NULL,
  CONSTRAINT `pk_usuarios` PRIMARY KEY (`run`),
  `dv` CHAR(1) NOT NULL,
  `nombre1` VARCHAR(25) NOT NULL,
  `nombre2` VARCHAR(25),
  `appaterno` VARCHAR(50) NOT NULL,
  `apmaterno` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `rol` VARCHAR(20) DEFAULT 'ESTUDIANTE' NOT NULL,
  `id_curso` INT,
  `img_perfil` VARCHAR(255),
  `activo` BOOLEAN DEFAULT 1 NOT NULL
);

ALTER TABLE `usuarios` ADD CONSTRAINT `fk_usuarios_cursos` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE SET NULL;

--changeset practika:auth-003-cursos-activo-legacy
-- Columnas legacy activo ya incluidas en CREATE TABLE.

--changeset practika:auth-004-usuarios-activo-legacy
-- Columnas legacy activo ya incluidas en CREATE TABLE.

--changeset practika:auth-100-dev-data context:@dev
INSERT INTO `cursos` (`id_curso`, `nivel_educativo`, `letra_curso`, `activo`) VALUES (1, '7° Básico', 'A', 1);

INSERT INTO `cursos` (`id_curso`, `nivel_educativo`, `letra_curso`, `activo`) VALUES (2, '7° Básico', 'B', 1);

INSERT INTO `cursos` (`id_curso`, `nivel_educativo`, `letra_curso`, `activo`) VALUES (3, '8° Básico', 'A', 1);

INSERT INTO `cursos` (`id_curso`, `nivel_educativo`, `letra_curso`, `activo`) VALUES (4, '8° Básico', 'B', 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `activo`) VALUES (11111111, '1', 'Admin', 'Practika', 'Demo', 'admin@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ADMIN', 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `activo`) VALUES (12345678, '5', 'Úrsula', 'Torres', 'Pérez', 'utp@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'UTP', 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345679, '3', 'Paula', 'Rojas', 'Soto', 'profesora1@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'PROFESOR', 1, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345671, '8', 'Pedro', 'Muñoz', 'Díaz', 'profesor2@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'PROFESOR', 2, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345682, '3', 'Carolina', 'Vega', 'Salas', 'profesora3@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'PROFESOR', 3, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345683, '1', 'Rodrigo', 'Mella', 'López', 'profesor4@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'PROFESOR', 4, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345670, 'K', 'Ana', 'Lagos', 'Vera', 'ana.lagos@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 1, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345672, '6', 'Benjamín', 'Pino', 'Leiva', 'benjamin.pino@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 1, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345673, '4', 'Camila', 'Reyes', 'Mora', 'camila.reyes@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 2, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345674, '2', 'Diego', 'Araya', 'Vidal', 'diego.araya@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 2, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345675, '0', 'Emilia', 'Silva', 'Riquelme', 'emilia.silva@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 3, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345676, '9', 'Felipe', 'Carrasco', 'Sáez', 'felipe.carrasco@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 3, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345677, '7', 'Gabriel', 'Fuentes', 'Núñez', 'gabriel.fuentes@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 4, 1);

INSERT INTO `usuarios` (`run`, `dv`, `nombre1`, `appaterno`, `apmaterno`, `email`, `password`, `rol`, `id_curso`, `activo`) VALUES (12345680, '7', 'Isidora', 'Contreras', 'Paz', 'isidora.contreras@practika.local', '$2a$10$bHJg79DGNkk/cpgJBkShzOIqvflzeS6PS9UlthkINrxqXnv91BuRG', 'ESTUDIANTE', 4, 1);

--changeset practika:auth-005-role-and-level-catalogs
CREATE TABLE `roles` (
  `id_rol` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(20) NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  CONSTRAINT `pk_roles` PRIMARY KEY (`id_rol`),
  CONSTRAINT `uq_roles_codigo` UNIQUE (`codigo`)
);

INSERT INTO `roles` (`codigo`, `nombre`)
SELECT DISTINCT `rol`, `rol` FROM `usuarios`;
INSERT IGNORE INTO `roles` (`codigo`, `nombre`) VALUES
('ESTUDIANTE', 'Estudiante'), ('PROFESOR', 'Profesor'), ('UTP', 'UTP'), ('ADMIN', 'Administrador');

CREATE TABLE `niveles_educativos` (
  `id_nivel_educativo` INT AUTO_INCREMENT NOT NULL,
  `codigo` VARCHAR(30) NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  `activo` BOOLEAN DEFAULT 1 NOT NULL,
  CONSTRAINT `pk_niveles_educativos` PRIMARY KEY (`id_nivel_educativo`),
  CONSTRAINT `uq_niveles_codigo` UNIQUE (`codigo`),
  CONSTRAINT `uq_niveles_nombre` UNIQUE (`nombre`)
);

INSERT INTO `niveles_educativos` (`codigo`, `nombre`)
SELECT DISTINCT `nivel_educativo`, `nivel_educativo` FROM `cursos`;
INSERT IGNORE INTO `niveles_educativos` (`codigo`, `nombre`) VALUES
('Prekínder', 'Prekínder'), ('Kínder', 'Kínder'),
('1° Básico', '1° Básico'), ('2° Básico', '2° Básico'), ('3° Básico', '3° Básico'), ('4° Básico', '4° Básico'),
('5° Básico', '5° Básico'), ('6° Básico', '6° Básico'), ('7° Básico', '7° Básico'), ('8° Básico', '8° Básico'),
('1° Medio', '1° Medio'), ('2° Medio', '2° Medio'), ('3° Medio', '3° Medio'), ('4° Medio', '4° Medio');

ALTER TABLE `cursos` ADD COLUMN `id_nivel_educativo` INT NULL;
UPDATE `cursos` c JOIN `niveles_educativos` n ON n.`nombre` = c.`nivel_educativo`
SET c.`id_nivel_educativo` = n.`id_nivel_educativo`;
ALTER TABLE `cursos` MODIFY `id_nivel_educativo` INT NOT NULL;
ALTER TABLE `cursos` ADD CONSTRAINT `fk_cursos_niveles_educativos`
  FOREIGN KEY (`id_nivel_educativo`) REFERENCES `niveles_educativos` (`id_nivel_educativo`);
ALTER TABLE `cursos` DROP COLUMN `nivel_educativo`;

ALTER TABLE `usuarios` ADD COLUMN `id_rol` INT NULL;
UPDATE `usuarios` u JOIN `roles` r ON r.`codigo` = u.`rol` SET u.`id_rol` = r.`id_rol`;
ALTER TABLE `usuarios` MODIFY `id_rol` INT NOT NULL;
ALTER TABLE `usuarios` ADD CONSTRAINT `fk_usuarios_roles`
  FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);
ALTER TABLE `usuarios` DROP COLUMN `rol`;

--changeset practika:auth-006-section-academic-year
ALTER TABLE `cursos` ADD COLUMN `anio` INT DEFAULT 2026 NOT NULL;
ALTER TABLE `cursos` ADD CONSTRAINT `uq_cursos_nivel_letra_anio`
  UNIQUE (`id_nivel_educativo`, `letra_curso`, `anio`);

--changeset practika:auth-007-rename-course-groups-as-sections
ALTER TABLE `usuarios` DROP FOREIGN KEY `fk_usuarios_cursos`;
ALTER TABLE `usuarios` CHANGE COLUMN `id_curso` `id_seccion` INT NULL;
ALTER TABLE `cursos` RENAME TO `secciones`;
ALTER TABLE `secciones` CHANGE COLUMN `id_curso` `id_seccion` INT NOT NULL;
ALTER TABLE `usuarios` ADD CONSTRAINT `fk_usuarios_secciones`
  FOREIGN KEY (`id_seccion`) REFERENCES `secciones` (`id_seccion`) ON DELETE SET NULL;

--changeset practika:auth-008-profile-photos
CREATE TABLE `fotos_perfil` (
  `run` INT PRIMARY KEY,
  `contenido` MEDIUMBLOB NOT NULL,
  CONSTRAINT `fk_fotos_perfil_usuario` FOREIGN KEY (`run`) REFERENCES `usuarios` (`run`) ON DELETE CASCADE
);

--changeset practika:auth-009-section-identity-and-enrollment-history
-- MySQL requires removing the referencing foreign key before changing the identity column.
ALTER TABLE `usuarios` DROP FOREIGN KEY `fk_usuarios_secciones`;
ALTER TABLE `secciones` MODIFY COLUMN `id_seccion` INT NOT NULL AUTO_INCREMENT;
ALTER TABLE `usuarios` ADD CONSTRAINT `fk_usuarios_secciones`
  FOREIGN KEY (`id_seccion`) REFERENCES `secciones` (`id_seccion`) ON DELETE SET NULL;

CREATE TABLE `matriculas` (
  `id_matricula` INT AUTO_INCREMENT PRIMARY KEY,
  `run_estudiante` INT NOT NULL,
  `id_seccion` INT NOT NULL,
  `fecha_inicio` DATETIME(6) NOT NULL,
  `fecha_fin` DATETIME(6) NULL,
  `activa` BOOLEAN NOT NULL DEFAULT 1,
  `origen` VARCHAR(20) NOT NULL DEFAULT 'ADMIN',
  `run_vigente` INT GENERATED ALWAYS AS (CASE WHEN `activa` = 1 THEN `run_estudiante` ELSE NULL END) STORED UNIQUE,
  CONSTRAINT `fk_matriculas_usuario` FOREIGN KEY (`run_estudiante`) REFERENCES `usuarios` (`run`),
  CONSTRAINT `fk_matriculas_seccion` FOREIGN KEY (`id_seccion`) REFERENCES `secciones` (`id_seccion`),
  CONSTRAINT `chk_matricula_fechas` CHECK (
    (`activa` = 1 AND `fecha_fin` IS NULL) OR
    (`activa` = 0 AND `fecha_fin` IS NOT NULL AND `fecha_fin` >= `fecha_inicio`))
);
CREATE INDEX `ix_matriculas_seccion` ON `matriculas` (`id_seccion`, `run_estudiante`);
INSERT INTO `matriculas` (`run_estudiante`, `id_seccion`, `fecha_inicio`, `activa`, `origen`)
SELECT u.`run`, u.`id_seccion`, CURRENT_TIMESTAMP(6), 1, 'MIGRACION'
FROM `usuarios` u JOIN `roles` r ON r.`id_rol` = u.`id_rol`
WHERE r.`codigo` = 'ESTUDIANTE' AND u.`id_seccion` IS NOT NULL;

--changeset practika:auth-010-grade-sections
--validCheckSum: 9:90ce5b2b6d65d080b9b4e6493ba6b679
-- MySQL commits DDL separately. Every structural step can resume after a partial failure.
UPDATE niveles_educativos SET activo = 0 WHERE codigo NOT IN ('1° Básico','2° Básico','3° Básico','4° Básico','5° Básico','6° Básico','7° Básico','8° Básico');
UPDATE niveles_educativos SET nombre = CASE codigo WHEN '1° Básico' THEN 'Primero básico' WHEN '2° Básico' THEN 'Segundo básico' WHEN '3° Básico' THEN 'Tercero básico' WHEN '4° Básico' THEN 'Cuarto básico' WHEN '5° Básico' THEN 'Quinto básico' WHEN '6° Básico' THEN 'Sexto básico' WHEN '7° Básico' THEN 'Séptimo básico' WHEN '8° Básico' THEN 'Octavo básico' ELSE nombre END;
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND COLUMN_NAME='id_seccion_canonica') > 0, 'SELECT 1', 'ALTER TABLE secciones ADD COLUMN id_seccion_canonica INT NULL');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
CREATE TABLE IF NOT EXISTS secciones_nivel_migracion AS SELECT id_nivel_educativo, MIN(id_seccion) AS id_canonica, MAX(COALESCE(activo,1)) AS activa FROM secciones GROUP BY id_nivel_educativo;
UPDATE secciones s JOIN secciones_nivel_migracion m ON s.id_seccion=m.id_canonica SET s.activo=m.activa;
UPDATE secciones s JOIN secciones_nivel_migracion m ON m.id_nivel_educativo=s.id_nivel_educativo SET s.id_seccion_canonica=m.id_canonica,s.activo=0 WHERE s.id_seccion<>m.id_canonica;
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='matriculas' AND COLUMN_NAME='id_seccion_origen') > 0, 'SELECT 1', 'ALTER TABLE matriculas ADD COLUMN id_seccion_origen INT NULL');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
UPDATE matriculas m JOIN secciones s ON s.id_seccion=m.id_seccion SET m.id_seccion_origen=m.id_seccion,m.id_seccion=s.id_seccion_canonica WHERE s.id_seccion_canonica IS NOT NULL;
UPDATE usuarios u JOIN secciones s ON s.id_seccion=u.id_seccion SET u.id_seccion=s.id_seccion_canonica WHERE s.id_seccion_canonica IS NOT NULL;
UPDATE secciones s JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo SET s.activo=0 WHERE n.activo=0;
-- The old unique index also supports the level foreign key; replace that support first.
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND INDEX_NAME='ix_secciones_nivel') > 0, 'SELECT 1', 'CREATE INDEX ix_secciones_nivel ON secciones(id_nivel_educativo)');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
SET @practika_ddl = IF((SELECT IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND INDEX_NAME='uq_cursos_nivel_letra_anio')=0,1,0)) > 0, 'SELECT 1', 'ALTER TABLE secciones DROP INDEX uq_cursos_nivel_letra_anio');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
ALTER TABLE secciones MODIFY letra_curso CHAR(1) NULL, MODIFY anio INT NULL;
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND COLUMN_NAME='nivel_vigente') > 0, 'SELECT 1', 'ALTER TABLE secciones ADD COLUMN nivel_vigente INT GENERATED ALWAYS AS (CASE WHEN id_seccion_canonica IS NULL THEN id_nivel_educativo ELSE NULL END) STORED');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND COLUMN_NAME='nivel_vigente' AND NON_UNIQUE=0) > 0, 'SELECT 1', 'CREATE UNIQUE INDEX uq_secciones_nivel_vigente ON secciones(nivel_vigente)');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
SET @practika_ddl = IF((SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='secciones' AND CONSTRAINT_NAME='fk_seccion_canonica') > 0, 'SELECT 1', 'ALTER TABLE secciones ADD CONSTRAINT fk_seccion_canonica FOREIGN KEY(id_seccion_canonica) REFERENCES secciones(id_seccion)');
PREPARE practika_migration FROM @practika_ddl;
EXECUTE practika_migration;
DEALLOCATE PREPARE practika_migration;
DROP TABLE IF EXISTS secciones_nivel_migracion;

--changeset practika:auth-011-mvp-demo-accounts context:@demo
-- Demo-only accounts. Existing accounts and section states are never overwritten.
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM usuarios WHERE run IN (20999001,20999002,20999101,20999211,20999212,20999213,20999214,20999102,20999221,20999222,20999223,20999224,20999103,20999231,20999232,20999233,20999234,20999104,20999241,20999242,20999243,20999244,20999105,20999251,20999252,20999253,20999254,20999106,20999261,20999262,20999263,20999264,20999107,20999271,20999272,20999273,20999274,20999108,20999281,20999282,20999283,20999284) OR email IN ('admin.demo@practika.example.test','utp.demo@practika.example.test','profesor1.demo@practika.example.test','estudiante11.demo@practika.example.test','estudiante12.demo@practika.example.test','estudiante13.demo@practika.example.test','estudiante14.demo@practika.example.test','profesor2.demo@practika.example.test','estudiante21.demo@practika.example.test','estudiante22.demo@practika.example.test','estudiante23.demo@practika.example.test','estudiante24.demo@practika.example.test','profesor3.demo@practika.example.test','estudiante31.demo@practika.example.test','estudiante32.demo@practika.example.test','estudiante33.demo@practika.example.test','estudiante34.demo@practika.example.test','profesor4.demo@practika.example.test','estudiante41.demo@practika.example.test','estudiante42.demo@practika.example.test','estudiante43.demo@practika.example.test','estudiante44.demo@practika.example.test','profesor5.demo@practika.example.test','estudiante51.demo@practika.example.test','estudiante52.demo@practika.example.test','estudiante53.demo@practika.example.test','estudiante54.demo@practika.example.test','profesor6.demo@practika.example.test','estudiante61.demo@practika.example.test','estudiante62.demo@practika.example.test','estudiante63.demo@practika.example.test','estudiante64.demo@practika.example.test','profesor7.demo@practika.example.test','estudiante71.demo@practika.example.test','estudiante72.demo@practika.example.test','estudiante73.demo@practika.example.test','estudiante74.demo@practika.example.test','profesor8.demo@practika.example.test','estudiante81.demo@practika.example.test','estudiante82.demo@practika.example.test','estudiante83.demo@practika.example.test','estudiante84.demo@practika.example.test')
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM secciones s JOIN niveles_educativos n ON n.id_nivel_educativo=s.id_nivel_educativo WHERE s.id_seccion_canonica IS NULL AND n.activo=1 AND s.activo=0
INSERT INTO secciones (id_nivel_educativo,activo)
SELECT n.id_nivel_educativo,1 FROM niveles_educativos n WHERE n.activo=1
AND NOT EXISTS(SELECT 1 FROM secciones s WHERE s.id_nivel_educativo=n.id_nivel_educativo AND s.id_seccion_canonica IS NULL);

INSERT INTO usuarios (run,dv,nombre1,appaterno,apmaterno,email,password,id_rol,id_seccion,activo)
SELECT d.run,d.dv,d.nombre,'Demo','MVP',d.email,
'$2a$10$hI5GdWuWNOxXlKnQ3LmlLuAV8c409Yfslg0077Hbo8/dRE5/SBhOu',r.id_rol,s.id_seccion,1
FROM (
SELECT 20999001 AS run,'6' AS dv,'Administrador' AS nombre,'admin.demo@practika.example.test' AS email,'ADMIN' AS rol,NULL AS nivel
UNION ALL SELECT 20999002 AS run,'4' AS dv,'UTP' AS nombre,'utp.demo@practika.example.test' AS email,'UTP' AS rol,NULL AS nivel
UNION ALL SELECT 20999101 AS run,'2' AS dv,'Profesor 1' AS nombre,'profesor1.demo@practika.example.test' AS email,'PROFESOR' AS rol,'1° Básico' AS nivel
UNION ALL SELECT 20999211 AS run,'6' AS dv,'Estudiante 11' AS nombre,'estudiante11.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'1° Básico' AS nivel
UNION ALL SELECT 20999212 AS run,'4' AS dv,'Estudiante 12' AS nombre,'estudiante12.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'1° Básico' AS nivel
UNION ALL SELECT 20999213 AS run,'2' AS dv,'Estudiante 13' AS nombre,'estudiante13.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'1° Básico' AS nivel
UNION ALL SELECT 20999214 AS run,'0' AS dv,'Estudiante 14' AS nombre,'estudiante14.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'1° Básico' AS nivel
UNION ALL SELECT 20999102 AS run,'0' AS dv,'Profesor 2' AS nombre,'profesor2.demo@practika.example.test' AS email,'PROFESOR' AS rol,'2° Básico' AS nivel
UNION ALL SELECT 20999221 AS run,'3' AS dv,'Estudiante 21' AS nombre,'estudiante21.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'2° Básico' AS nivel
UNION ALL SELECT 20999222 AS run,'1' AS dv,'Estudiante 22' AS nombre,'estudiante22.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'2° Básico' AS nivel
UNION ALL SELECT 20999223 AS run,'K' AS dv,'Estudiante 23' AS nombre,'estudiante23.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'2° Básico' AS nivel
UNION ALL SELECT 20999224 AS run,'8' AS dv,'Estudiante 24' AS nombre,'estudiante24.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'2° Básico' AS nivel
UNION ALL SELECT 20999103 AS run,'9' AS dv,'Profesor 3' AS nombre,'profesor3.demo@practika.example.test' AS email,'PROFESOR' AS rol,'3° Básico' AS nivel
UNION ALL SELECT 20999231 AS run,'0' AS dv,'Estudiante 31' AS nombre,'estudiante31.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'3° Básico' AS nivel
UNION ALL SELECT 20999232 AS run,'9' AS dv,'Estudiante 32' AS nombre,'estudiante32.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'3° Básico' AS nivel
UNION ALL SELECT 20999233 AS run,'7' AS dv,'Estudiante 33' AS nombre,'estudiante33.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'3° Básico' AS nivel
UNION ALL SELECT 20999234 AS run,'5' AS dv,'Estudiante 34' AS nombre,'estudiante34.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'3° Básico' AS nivel
UNION ALL SELECT 20999104 AS run,'7' AS dv,'Profesor 4' AS nombre,'profesor4.demo@practika.example.test' AS email,'PROFESOR' AS rol,'4° Básico' AS nivel
UNION ALL SELECT 20999241 AS run,'8' AS dv,'Estudiante 41' AS nombre,'estudiante41.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'4° Básico' AS nivel
UNION ALL SELECT 20999242 AS run,'6' AS dv,'Estudiante 42' AS nombre,'estudiante42.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'4° Básico' AS nivel
UNION ALL SELECT 20999243 AS run,'4' AS dv,'Estudiante 43' AS nombre,'estudiante43.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'4° Básico' AS nivel
UNION ALL SELECT 20999244 AS run,'2' AS dv,'Estudiante 44' AS nombre,'estudiante44.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'4° Básico' AS nivel
UNION ALL SELECT 20999105 AS run,'5' AS dv,'Profesor 5' AS nombre,'profesor5.demo@practika.example.test' AS email,'PROFESOR' AS rol,'5° Básico' AS nivel
UNION ALL SELECT 20999251 AS run,'5' AS dv,'Estudiante 51' AS nombre,'estudiante51.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'5° Básico' AS nivel
UNION ALL SELECT 20999252 AS run,'3' AS dv,'Estudiante 52' AS nombre,'estudiante52.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'5° Básico' AS nivel
UNION ALL SELECT 20999253 AS run,'1' AS dv,'Estudiante 53' AS nombre,'estudiante53.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'5° Básico' AS nivel
UNION ALL SELECT 20999254 AS run,'K' AS dv,'Estudiante 54' AS nombre,'estudiante54.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'5° Básico' AS nivel
UNION ALL SELECT 20999106 AS run,'3' AS dv,'Profesor 6' AS nombre,'profesor6.demo@practika.example.test' AS email,'PROFESOR' AS rol,'6° Básico' AS nivel
UNION ALL SELECT 20999261 AS run,'2' AS dv,'Estudiante 61' AS nombre,'estudiante61.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'6° Básico' AS nivel
UNION ALL SELECT 20999262 AS run,'0' AS dv,'Estudiante 62' AS nombre,'estudiante62.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'6° Básico' AS nivel
UNION ALL SELECT 20999263 AS run,'9' AS dv,'Estudiante 63' AS nombre,'estudiante63.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'6° Básico' AS nivel
UNION ALL SELECT 20999264 AS run,'7' AS dv,'Estudiante 64' AS nombre,'estudiante64.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'6° Básico' AS nivel
UNION ALL SELECT 20999107 AS run,'1' AS dv,'Profesor 7' AS nombre,'profesor7.demo@practika.example.test' AS email,'PROFESOR' AS rol,'7° Básico' AS nivel
UNION ALL SELECT 20999271 AS run,'K' AS dv,'Estudiante 71' AS nombre,'estudiante71.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'7° Básico' AS nivel
UNION ALL SELECT 20999272 AS run,'8' AS dv,'Estudiante 72' AS nombre,'estudiante72.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'7° Básico' AS nivel
UNION ALL SELECT 20999273 AS run,'6' AS dv,'Estudiante 73' AS nombre,'estudiante73.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'7° Básico' AS nivel
UNION ALL SELECT 20999274 AS run,'4' AS dv,'Estudiante 74' AS nombre,'estudiante74.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'7° Básico' AS nivel
UNION ALL SELECT 20999108 AS run,'K' AS dv,'Profesor 8' AS nombre,'profesor8.demo@practika.example.test' AS email,'PROFESOR' AS rol,'8° Básico' AS nivel
UNION ALL SELECT 20999281 AS run,'7' AS dv,'Estudiante 81' AS nombre,'estudiante81.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'8° Básico' AS nivel
UNION ALL SELECT 20999282 AS run,'5' AS dv,'Estudiante 82' AS nombre,'estudiante82.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'8° Básico' AS nivel
UNION ALL SELECT 20999283 AS run,'3' AS dv,'Estudiante 83' AS nombre,'estudiante83.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'8° Básico' AS nivel
UNION ALL SELECT 20999284 AS run,'1' AS dv,'Estudiante 84' AS nombre,'estudiante84.demo@practika.example.test' AS email,'ESTUDIANTE' AS rol,'8° Básico' AS nivel
 ) d JOIN roles r ON r.codigo=d.rol
LEFT JOIN niveles_educativos n ON n.codigo=d.nivel
LEFT JOIN secciones s ON s.id_nivel_educativo=n.id_nivel_educativo AND s.id_seccion_canonica IS NULL;

INSERT INTO matriculas (run_estudiante,id_seccion,fecha_inicio,activa,origen)
SELECT u.run,u.id_seccion,CURRENT_TIMESTAMP(6),1,'DEMO'
FROM usuarios u JOIN roles r ON r.id_rol=u.id_rol
WHERE r.codigo='ESTUDIANTE' AND u.id_seccion IS NOT NULL
AND u.run IN (20999001,20999002,20999101,20999211,20999212,20999213,20999214,20999102,20999221,20999222,20999223,20999224,20999103,20999231,20999232,20999233,20999234,20999104,20999241,20999242,20999243,20999244,20999105,20999251,20999252,20999253,20999254,20999106,20999261,20999262,20999263,20999264,20999107,20999271,20999272,20999273,20999274,20999108,20999281,20999282,20999283,20999284)
AND NOT EXISTS (SELECT 1 FROM matriculas m WHERE m.run_estudiante=u.run AND m.activa=1);
