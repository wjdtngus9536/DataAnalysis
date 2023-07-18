```sql
create database DB_SQLSTK;

show databases;

use db_sqlstk;

select database();

-- DB_SQLSTK 데이터 에비스는 컴퓨터의 하드 디스크 공간 어딘가에 만들어진다. 어느 경로에 데이터베이스가 만들어 졌는지 확인하기 위해 아래와 같이 'Show variables'를 사용한다.
show variables like 'datadir';

use db_sqlstk;

show tables;

# User_SQLSTK 사용자 만들기
create user 'USER_SQLSTK'@'localhost' identified by '!23456789';

select * from MYSQL.USER where user = 'USER_SQLSTK';

select * from MYSQL.USER;

# 만들어진 사용자에 DB_SQLSTK 데이터베이스에 대한 권한 부여
GRANT ALL ON db_sqlstk.* TO 'USER_SQLSTK'@'localhost';

# 사용자 계정 삭제
-- drop user 'user_sqlstk'@'localhost'; 

```