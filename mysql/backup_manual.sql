-- ============================================
-- 数据库备份与恢复 — SQL 手册
-- 适用课程：数据库原理与技术实习A
-- 说明：本文件展示两种备份/恢复方式，
--        满足课程设计对"数据备份与恢复功能"的考察要求。
-- ============================================

-- -------------------------------------------------
-- 方式一：mysqldump / mysql 命令行（生产环境推荐）
-- -------------------------------------------------

-- 【备份全库】
-- 在 Windows 命令提示符（cmd）中执行：
--   mysqldump -uroot -p<your_password> --single-transaction --routines --triggers --databases water_quality_db > backup.sql

-- 【恢复全库】
--   mysql -uroot -p<your_password> water_quality_db < backup.sql

-- -------------------------------------------------
-- 方式二：SELECT INTO OUTFILE / LOAD DATA（表级）
-- 先开启 secure_file_priv 权限或在 Navicat 中操作
-- -------------------------------------------------

-- 【备份单表 — 导出为 CSV】
-- SELECT * FROM water_detection
--   INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/water_detection.csv'
--   FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- 【恢复单表 — 从 CSV 导入】
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/water_detection.csv'
--   INTO TABLE water_detection
--   FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- -------------------------------------------------
-- 方式三：CREATE TABLE ... SELECT（表结构+数据复制）
-- -------------------------------------------------

-- 【创建备份表 — 一次性复制结构和数据】
-- DROP TABLE IF EXISTS water_detection_backup_20260605;
-- CREATE TABLE water_detection_backup_20260605 AS
--   SELECT * FROM water_detection;

-- 【从备份表恢复数据】
-- DELETE FROM water_detection;
-- INSERT INTO water_detection SELECT * FROM water_detection_backup_20260605;

-- -------------------------------------------------
-- 方式四：存储过程 — 一键备份所有表的时间戳快照
-- -------------------------------------------------

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_backup_all_tables(
    IN snapshot_suffix VARCHAR(50)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tbl_name VARCHAR(128);
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = 'water_quality_db' AND TABLE_TYPE = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO tbl_name;
        IF done THEN LEAVE read_loop; END IF;

        SET @sql = CONCAT(
            'DROP TABLE IF EXISTS ', tbl_name, '_backup_', snapshot_suffix
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT(
            'CREATE TABLE ', tbl_name, '_backup_', snapshot_suffix, ' AS SELECT * FROM ', tbl_name
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

-- 【调用示例】
-- CALL sp_backup_all_tables('20260605');

-- -------------------------------------------------
-- 方式五：事件调度 — 每日自动备份 water_detection
-- -------------------------------------------------

DROP EVENT IF EXISTS evt_daily_detection_backup;
CREATE EVENT evt_daily_detection_backup
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_TIMESTAMP
DO
BEGIN
    SET @backup_name = CONCAT('water_detection_auto_', DATE_FORMAT(NOW(), '%Y%m%d'));
    SET @sql = CONCAT('DROP TABLE IF EXISTS ', @backup_name);
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('CREATE TABLE ', @backup_name, ' AS SELECT * FROM water_detection');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
END;

-- 【查看事件状态】
-- SHOW EVENTS;
-- 【停止自动备份】
-- DROP EVENT IF EXISTS evt_daily_detection_backup;
