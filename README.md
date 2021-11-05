# MySQL

>terminal 창에서 아래와 같이 서버 열고 닫기
>
>`mysql.server start` : MySQL 서버 시작
>
>`mysql -uroot -p` + 패스워드 입력 : MySQL 로컬 DB 로그인
>
>`exit` or `quit` : terminal 에서 MySQL 끝내기
>
>`mysql.server stop` : MySQL 서버 종료

<br>

<br>

---

### SQL (Structured Query Language)

- DML 데이터 조작 언어

  -SELECT (검색/선택)

  -UPDATE (수정/변경)

  -INSERT (삽입)

  -DELETE (삭제)

  <br>

- DDL 데이터 정의 언어 : 데이터베이스, 테이블, 뷰(가상 테이블), 인덱스

  -CREATE (생성)

  -DROP (삭제)

  -ALTER (변경)

  <br>

- DCL 데이터 조작 언어

  -GRANT : 권한 부여

  -REVOKE : 권한 박탈, 회수

  -DENY

  <br>
  
  <br>

---

* `show databases;` : 현재 연결된 데이터베이스 목록을 보여줌

* `USE DB이름;` : 사용할 데이터베이스 지정, 지정하지 않으면 기존에 사용하던 DB에서 진행됨

* 테이블 구조 확인

  -`DESCRIBE 테이블명;`
  
  -`desc 테이블명;` 
  
  -`explain 테이블명;` 

* `select database();` : 현재 사용하고 있는 데이터베이스를 보여줌

