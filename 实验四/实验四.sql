SET NAMES utf8mb4;

SELECT '实验4：安全性控制' AS title;

DROP DATABASE IF EXISTS db_lab4;
CREATE DATABASE db_lab4 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE db_lab4;

SELECT '实验4.1：自主存取控制（用户/角色/授权/回收）' AS step;

DROP VIEW IF EXISTS V_MY_EMP;
DROP VIEW IF EXISTS V_DEPT_SALARY_STATS;

DROP TABLE IF EXISTS 学生;
DROP TABLE IF EXISTS 班级;
DROP TABLE IF EXISTS 职工;
DROP TABLE IF EXISTS 部门;

CREATE TABLE 班级 (
    班级号 VARCHAR(20) PRIMARY KEY,
    班级名 VARCHAR(50),
    班主任 VARCHAR(50),
    班长 VARCHAR(50)
) DEFAULT CHARSET = utf8mb4;

CREATE TABLE 学生 (
    学号 VARCHAR(20) PRIMARY KEY,
    姓名 VARCHAR(50),
    年龄 INT,
    性别 VARCHAR(10),
    家庭住址 VARCHAR(200),
    班级号 VARCHAR(20),
    FOREIGN KEY (班级号) REFERENCES 班级(班级号)
) DEFAULT CHARSET = utf8mb4;

CREATE TABLE 部门 (
    部门号 VARCHAR(20) PRIMARY KEY,
    名称 VARCHAR(50),
    经理名 VARCHAR(50),
    地址 VARCHAR(200),
    电话号 VARCHAR(30)
) DEFAULT CHARSET = utf8mb4;

CREATE TABLE 职工 (
    职工号 VARCHAR(20) PRIMARY KEY,
    姓名 VARCHAR(50),
    年龄 INT,
    职务 VARCHAR(50),
    工资 DECIMAL(12,2),
    部门号 VARCHAR(20),
    FOREIGN KEY (部门号) REFERENCES 部门(部门号)
) DEFAULT CHARSET = utf8mb4;

INSERT INTO 班级 (班级号, 班级名, 班主任, 班长) VALUES
('C01', '计科1班', '李老师', '张三'),
('C02', '计科2班', '王老师', '李四');

INSERT INTO 学生 (学号, 姓名, 年龄, 性别, 家庭住址, 班级号) VALUES
('2024001', '张三', 19, '男', '上海市浦东新区', 'C01'),
('2024002', '李四', 20, '女', '天津市南开区', 'C01'),
('2024003', '王芳', 19, '女', '北京市海淀区', 'C02');

INSERT INTO 部门 (部门号, 名称, 经理名, 地址, 电话号) VALUES
('D01', '研发部', '周平', '上海', '021-10000001'),
('D02', '财务部', '杨兰', '北京', '010-20000002'),
('D03', '生产部', '王明', '天津', '022-30000003');

INSERT INTO 职工 (职工号, 姓名, 年龄, 职务, 工资, 部门号) VALUES
('E01', '王明', 35, '工程师', 18000.00, 'D01'),
('E02', '李勇', 28, '会计', 12000.00, 'D02'),
('E03', '刘星', 30, '工程师', 16000.00, 'D01'),
('E04', '张新', 40, '主管', 20000.00, 'D03'),
('E05', '周平', 45, '经理', 26000.00, 'D01'),
('E06', '杨兰', 38, '经理', 24000.00, 'D02');

SELECT '4.1-0：创建用户与角色' AS q;

DROP USER IF EXISTS 'U1'@'localhost';
DROP USER IF EXISTS 'U2'@'localhost';
DROP USER IF EXISTS '王明'@'localhost';
DROP USER IF EXISTS '李勇'@'localhost';
DROP USER IF EXISTS '刘星'@'localhost';
DROP USER IF EXISTS '张新'@'localhost';
DROP USER IF EXISTS '周平'@'localhost';
DROP USER IF EXISTS '杨兰'@'localhost';

DROP ROLE IF EXISTS 'R1';
DROP ROLE IF EXISTS 'R_PUBLIC';
DROP ROLE IF EXISTS 'R_EMP_SELF';

CREATE USER 'U1'@'localhost' IDENTIFIED BY 'U1_123456';
CREATE USER 'U2'@'localhost' IDENTIFIED BY 'U2_123456';
CREATE USER '王明'@'localhost' IDENTIFIED BY 'wm_123456';
CREATE USER '李勇'@'localhost' IDENTIFIED BY 'ly_123456';
CREATE USER '刘星'@'localhost' IDENTIFIED BY 'lx_123456';
CREATE USER '张新'@'localhost' IDENTIFIED BY 'zx_123456';
CREATE USER '周平'@'localhost' IDENTIFIED BY 'zp_123456';
CREATE USER '杨兰'@'localhost' IDENTIFIED BY 'yl_123456';

CREATE ROLE 'R1';
CREATE ROLE 'R_PUBLIC';
CREATE ROLE 'R_EMP_SELF';

SELECT '4.1-5：对 学生/班级 表完成授权（题5①~⑤）' AS q;

GRANT ALL PRIVILEGES ON db_lab4.学生 TO 'U1'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_lab4.班级 TO 'U1'@'localhost' WITH GRANT OPTION;

GRANT SELECT ON db_lab4.学生 TO 'U2'@'localhost';
GRANT UPDATE (家庭住址) ON db_lab4.学生 TO 'U2'@'localhost';

GRANT SELECT ON db_lab4.班级 TO 'R_PUBLIC';

GRANT SELECT, UPDATE ON db_lab4.学生 TO 'R1';
GRANT 'R1' TO 'U1'@'localhost' WITH ADMIN OPTION;

GRANT 'R_PUBLIC' TO 'U1'@'localhost', 'U2'@'localhost', '王明'@'localhost', '李勇'@'localhost', '刘星'@'localhost', '张新'@'localhost', '周平'@'localhost', '杨兰'@'localhost';

SELECT '4.1-6：对 职工/部门 表完成授权（题6①~⑦）' AS q;

GRANT SELECT ON db_lab4.职工 TO '王明'@'localhost';
GRANT SELECT ON db_lab4.部门 TO '王明'@'localhost';

GRANT INSERT, DELETE ON db_lab4.职工 TO '李勇'@'localhost';
GRANT INSERT, DELETE ON db_lab4.部门 TO '李勇'@'localhost';

CREATE VIEW V_MY_EMP SQL SECURITY INVOKER AS
SELECT *
FROM 职工
WHERE 姓名 = SUBSTRING_INDEX(USER(), '@', 1);

GRANT SELECT ON db_lab4.V_MY_EMP TO 'R_EMP_SELF';
GRANT 'R_EMP_SELF' TO '王明'@'localhost', '李勇'@'localhost', '刘星'@'localhost', '张新'@'localhost', '周平'@'localhost', '杨兰'@'localhost';

GRANT SELECT ON db_lab4.职工 TO '刘星'@'localhost';
GRANT UPDATE (工资) ON db_lab4.职工 TO '刘星'@'localhost';

GRANT ALTER ON db_lab4.职工 TO '张新'@'localhost';
GRANT ALTER ON db_lab4.部门 TO '张新'@'localhost';

GRANT ALL PRIVILEGES ON db_lab4.职工 TO '周平'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_lab4.部门 TO '周平'@'localhost' WITH GRANT OPTION;

CREATE VIEW V_DEPT_SALARY_STATS AS
SELECT 部门号, MAX(工资) AS 最高工资, MIN(工资) AS 最低工资, AVG(工资) AS 平均工资
FROM 职工
GROUP BY 部门号;

GRANT SELECT ON db_lab4.V_DEPT_SALARY_STATS TO '杨兰'@'localhost';

SELECT '4.1-验证：查看授权结果' AS q;

SHOW GRANTS FOR 'U1'@'localhost';
SHOW GRANTS FOR 'U2'@'localhost';
SHOW GRANTS FOR '王明'@'localhost';
SHOW GRANTS FOR '李勇'@'localhost';
SHOW GRANTS FOR '刘星'@'localhost';
SHOW GRANTS FOR '张新'@'localhost';
SHOW GRANTS FOR '周平'@'localhost';
SHOW GRANTS FOR '杨兰'@'localhost';

SELECT '4.1-7：撤销题6①~⑦各用户权限（题7）' AS q;

REVOKE SELECT ON db_lab4.职工 FROM '王明'@'localhost';
REVOKE SELECT ON db_lab4.部门 FROM '王明'@'localhost';

REVOKE INSERT, DELETE ON db_lab4.职工 FROM '李勇'@'localhost';
REVOKE INSERT, DELETE ON db_lab4.部门 FROM '李勇'@'localhost';

REVOKE 'R_EMP_SELF' FROM '王明'@'localhost', '李勇'@'localhost', '刘星'@'localhost', '张新'@'localhost', '周平'@'localhost', '杨兰'@'localhost';
REVOKE SELECT ON db_lab4.V_MY_EMP FROM 'R_EMP_SELF';

REVOKE SELECT ON db_lab4.职工 FROM '刘星'@'localhost';
REVOKE UPDATE (工资) ON db_lab4.职工 FROM '刘星'@'localhost';

REVOKE ALTER ON db_lab4.职工 FROM '张新'@'localhost';
REVOKE ALTER ON db_lab4.部门 FROM '张新'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION ON db_lab4.职工 FROM '周平'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION ON db_lab4.部门 FROM '周平'@'localhost';

REVOKE SELECT ON db_lab4.V_DEPT_SALARY_STATS FROM '杨兰'@'localhost';

SELECT '4.1-验证：撤权后查看授权结果（题7）' AS q;

SHOW GRANTS FOR '王明'@'localhost';
SHOW GRANTS FOR '李勇'@'localhost';
SHOW GRANTS FOR '刘星'@'localhost';
SHOW GRANTS FOR '张新'@'localhost';
SHOW GRANTS FOR '周平'@'localhost';
SHOW GRANTS FOR '杨兰'@'localhost';

SELECT '实验4.2：审计实验（MySQL 通用查询日志示例）' AS step;

SET GLOBAL log_output = 'TABLE';
SET GLOBAL general_log = 'ON';

SELECT '4.2-1：执行几条SQL以产生审计记录' AS q;
SELECT COUNT(*) AS 学生人数 FROM 学生;
SELECT COUNT(*) AS 职工人数 FROM 职工;

SELECT '4.2-2：查看审计记录（mysql.general_log）' AS q;
SELECT event_time, user_host, argument
FROM mysql.general_log
WHERE command_type = 'Query'
ORDER BY event_time DESC
LIMIT 50;

SET GLOBAL general_log = 'OFF';
