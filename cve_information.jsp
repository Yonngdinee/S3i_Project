<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@page import="page.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%!// 변수 선언
  Connection conn = null; //DB연결
  PreparedStatement ps;
  ResultSet rs; //쿼리생성
  String color_v2 = "black"; //2버전 글자 색상
  String color_v3 = "black";//3버전 글자 색상
  SettingSQL p = new SettingSQL(); // 기본 SQL문 변경 객체 생성
  String sql;
  int count; //전체 레코드 갯수%>

<!DOCTYPE html>
<html>

<head>
<link rel="stylesheet" type="text/css" href="db.css" />
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
<title>CVE 통합 검색</title>

</head>

<body>
  <header>
    <!--title -->
    <div class="title_main">
      <!-- CVE(Common Vulnerabilities and Exposures)는 공개적으로 알려진 컴퓨터 보안 결함 목록입니다. CVE는 보통 CVE ID 번호가 할당된 보안 결함을 뜻합니다. -->
      <a style="cursor: pointer;" onclick="location = 'cve_information.jsp'">CVE 통합 검색 </a>
      <a style="text-align: center; color: #5B8FB9; font-size: 20px; font-weight: 400;">
        <br>Common Vulnerabilities and Exposures
      </a>

    </div>
    <!-- 검색 바 -->
    <section class=search>
      <div class="searchBlock">
        <form action="cve_information.jsp" method="get">
          <input id="searchVal" name="search" type="text" placeholder="CVE-ID나 키워드, 날짜(xxxx-xx-xx)를 입력하세요 ">
          <input id="btnSearch" name="btnSearch" type="image" src="search.png" alt="검색">
        </form>
      </div>

    </section>
  </header>
  <main>
    <%!/* 페이지 int형 변환 */

  public Integer toInt(String x) {
    int a = 0;
    try {
      a = Integer.parseInt(x);
    } catch (Exception e) {
    }
    return a;
  }%>
    <%
    String search = request.getParameter("search"); // 검색어 값 가져오기
    try {
      count = 0;
      Context init = new InitialContext(); // 커넥션 풀 1
      DataSource ds = (DataSource) init.lookup("java:comp/env/jdbc/cveDB"); // 커넥션 풀 2 
      conn = ds.getConnection(); // 커넥션 풀 3
      p.setSql("SELECT * " + "FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL"); // 전체 레코드 값 구할 Sql

      if (search != null) { // 검색 했을 시 전체 레코드 값 구할 Sql
        String sql1 = "SELECT * FROM cve_information " + "WHERE (cveid" + " LIKE " + "'%" + search + "%'" + "OR" + " description" + " LIKE " + "'%" + search + "%'" + "OR" + " descriptionKR" + " LIKE " + "'%" + search + "%'" + "OR" + " publish_date" + " LIKE " + "'%" + search + "%'" + "OR" + " update_date" + " LIKE " + "'%" + search + "%')" + " AND cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY cveid DESC";
        p.setSql(sql1);
      }
      String k = p.getSql();
      k = k.replaceAll("[*]", "cveid"); // select * form 에서 * 제거 <- 딜레이의 원인이므로 필수 
      ps = conn.prepareStatement(k);
      rs = ps.executeQuery();

      while (rs.next()) {
        count++; // 전체 레코드 개수 카운트

      }

    } catch (Exception ex) {
      System.out.println("DB연결 실패:" + ex);

    }

    int pageno = toInt(request.getParameter("pageno")); // 전체 페이지 갯수

    if (pageno < 1) {
      pageno = 1;
    }
    int total_record = count; // p.resultPage(); //총 레코드 수
    int page_per_record_cnt = 10; //페이지 당 레코드 수
    int group_per_page_cnt = 10; //페이지 당 보여줄 번호 수                 

    int record_end_no = pageno * page_per_record_cnt;
    int record_start_no = record_end_no - (page_per_record_cnt - 1);
    if (record_end_no > total_record) {
      record_end_no = total_record;
    }

    int total_page = total_record / page_per_record_cnt + (total_record % page_per_record_cnt > 0 ? 1 : 0);
    if (pageno > total_page) {
      pageno = total_page;
    }

    //  현재 페이지/ 한페이지 당 보여줄 페지 번호 수 + (현재 페이지 % 한 페이지 당 보여줄 페이지 번호 수 >0 ? 1 : 0)
    int group_no = pageno / group_per_page_cnt + (pageno % group_per_page_cnt > 0 ? 1 : 0);
    //  현재 그룹번호 = 현재페이지 / 페이지당 보여줄 번호수 (현재 페이지 % 페이지당 보여줄 번호 수 >0 ? 1:0)  
    int page_eno = group_no * group_per_page_cnt;
    //  현재 그룹 끝 번호 = 현재 그룹번호 * 페이지당 보여줄 번호 
    int page_sno = page_eno - (group_per_page_cnt - 1);
    //  현재 그룹 시작 번호 = 현재 그룹 끝 번호 - (페이지당 보여줄 번호 수 -1)

    if (page_eno > total_page) {
      //  현재 그룹 끝 번호가 전체페이지 수 보다 클 경우   
      page_eno = total_page;
      //  현재 그룹 끝 번호와 = 전체페이지 수를 같게
    }

    int prev_pageno = page_sno - group_per_page_cnt;
    //  이전 페이지 번호 = 현재 그룹 시작 번호 - 페이지당 보여줄 번호수        
    int next_pageno = page_sno + group_per_page_cnt;
    //  다음 페이지 번호 = 현재 그룹 시작 번호 + 페이지당 보여줄 번호수

    if (prev_pageno < 1) {
      //  이전 페이지 번호가 1보다 작을 경우    
      prev_pageno = 1;
      //  이전 페이지를 1로
    }
    if (next_pageno > total_page) {
      //  다음 페이지보다 전체페이지 수보가 클경우    
      next_pageno = total_page / group_per_page_cnt * group_per_page_cnt + 1;
      //  다음 페이지 = 전체페이지수 / 페이지당 보여줄 번호수 * 페이지당 보여줄 번호수 + 1   
    }
    %>

    <!--정렬 버튼 -->
    <form id=sortbu method="get" action="cve_information.jsp">
      <input type="radio" name="check" value="l2high">
      v2높은점수순
      <input type="radio" name="check" value="l2low">
      v2낮은점수순
      <input type="radio" name="check" value="l3high">
      v3높은점수순
      <input type="radio" name="check" value="l3low">
      v3낮은점수순 &nbsp;&nbsp;
      <input type="submit" value="적용" id="apply">
    </form>

    <%
    request.setCharacterEncoding("euc-kr"); // 파라미터값이 한글인 경우 
    String check = request.getParameter("check"); // 라디오 값 가져오기

    try {
      //cve_information table에서 null값을 제외한 모든 컬럼값을 불러오는데 가장 최신것은 예약된이므로 예약된을 맨 뒤로 보내고 id를 기준으로 내림차순한다.
      sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL " + "ORDER BY descriptionKR = '예약된',description = 'reserved', cveid DESC " + "LIMIT 10 OFFSET " + (record_start_no - 1);

      ps = conn.prepareStatement(sql);
      /* 검색어 처리 */
      if (search != null) {
        sql = "SELECT * FROM cve_information WHERE (cveid" + " LIKE " + "'%" + search + "%'" + "OR" + " description" + " LIKE " + "'%" + search + "%'" + "OR" + " descriptionKR" + " LIKE " + "'%" + search + "%'" + "OR" + " publish_date" + " LIKE " + "'%" + search + "%'" + "OR" + " update_date" + " LIKE " + "'%" + search + "%')" + " AND cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY descriptionKR = '예약된', cveid DESC LIMIT 10 OFFSET " + (record_start_no - 1);
        total_record = count;
        total_page = total_record / page_per_record_cnt + (total_record % page_per_record_cnt > 0 ? 1 : 0); // 총 페이지 초기화
        group_no = pageno / group_per_page_cnt + (pageno % group_per_page_cnt > 0 ? 1 : 0); // 현재 그룹 번호 초기화 
        page_eno = group_no * group_per_page_cnt; // 마지막 페이지 초기화 
        if (page_eno > total_page) { //  현재 그룹 끝 번호가 전체페이지 수 보다 클 경우    
      page_eno = total_page; //  현재 그룹 끝 번호와 = 전체페이지 수를 같게
        }

      }

      /* 라디오 값 처리 */
      if (check != null) {
        if (check.equals("l2high")) {
      sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v2_score AS SIGNED) DESC,description = 'reserved', descriptionKR = '예약된', cveid DESC LIMIT 10 OFFSET " + (record_start_no - 1);
      String sql1 = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v2_score AS SIGNED) DESC, descriptionKR = '예약된', cveid DESC";
      p.setSql(sql1);

        }

        if (check.equals("l2low")) {

      sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v2_score AS SIGNED),description = 'reserved', descriptionKR = '예약된', cveid DESC LIMIT 10 OFFSET " + (record_start_no - 1);
      String sql1 = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v2_score AS SIGNED), descriptionKR = '예약된', cveid DESC";
      p.setSql(sql1);

        }
        if (check.equals("l3high")) {
      sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v3_score AS SIGNED) DESC, description = 'reserved', descriptionKR = '예약된', cveid DESC LIMIT 10 OFFSET " + (record_start_no - 1);
      String sql1 = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v3_score AS SIGNED) DESC, descriptionKR = '예약된', cveid DESC";
      p.setSql(sql1);
        }

        if (check.equals("l3low")) {
      sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v3_score AS SIGNED), description = 'reserved', descriptionKR = '예약된', cveid DESC LIMIT 10 OFFSET " + (record_start_no - 1);
      String sql1 = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL ORDER BY CAST(cvss_v3_score AS SIGNED), description = 'reserved', descriptionKR = '예약된', descriptionKR = '예약된', cveid DESC";
      p.setSql(sql1);
        }
      }
    %>
    <p id=page-information>
      총<%=total_record%>건 &nbsp; 총<%=total_page%>페이지
    </p>

    <%
    rs = ps.executeQuery(sql); // 쿼리생성

    /* 레벨 별로 색상 변경 */
    while (rs.next()) {
      // alert()함수 주석처리를 위해 변수에 저장
      String description = rs.getString("description");
      pageContext.setAttribute("description", description);
      String descriptionKR = rs.getString("descriptionKR");
      pageContext.setAttribute("descriptionKR", descriptionKR);
      String cvss_v2_score = rs.getString("cvss_v2_score"); //변경됨
      String cvss_v3_score = rs.getString("cvss_v3_score"); //변경됨
      String cvss_v2_lv = rs.getString("cvss_v2_lv"); // 변경됨
      String cvss_v3_lv = rs.getString("cvss_v3_lv"); // 변경됨
      String cvss_v3_version = rs.getString("cvss_v3_version");

      if (cvss_v2_score.equals("none")) { // 변경됨
        cvss_v2_score = "미 발표";
        color_v2 = "black";
      }
      if (cvss_v3_score.equals("none")) { // 변경됨
        cvss_v3_score = "미 발표";
        color_v3 = "black";
      }
      if (cvss_v2_lv.equals("none")) { // 변경됨
        cvss_v2_lv = "미 발표";
        color_v2 = "black";
      }
      if (cvss_v3_lv.equals("none")) { // 변경됨
        cvss_v3_lv = "미 발표";
        color_v3 = "black";
      }
      if (cvss_v3_version.equals("none")) { // 변경됨
        cvss_v3_version = "미 발표";

      }

      //색상 처리
      if (rs.getString("cvss_v2_lv").equals("HIGH") || rs.getString("cvss_v2_lv").equals("CRITICAL")) {
        color_v2 = "red";
      } else if (rs.getString("cvss_v2_lv").equals("MEDIUM")) {
        color_v2 = " #f7570b";
      } else if (rs.getString("cvss_v2_lv").equals("LOW")) {
        color_v2 = "#1e7e17";
      } else {
        color_v2 = "black";
      }

      if (rs.getString("cvss_v3_lv") != null) {
        if (rs.getString("cvss_v3_lv").equals("HIGH") || rs.getString("cvss_v3_lv").equals("CRITICAL")) {
      color_v3 = "red";
        } else if (rs.getString("cvss_v3_lv").equals("MEDIUM")) {
      color_v3 = " #f7570b";
        } else if (rs.getString("cvss_v3_lv").equals("LOW")) {
      color_v3 = "#1e7e17";
        }
      } else {
        color_v3 = "black";
      }
    %>
    <br>
    <!-- DB데이터값 출력 부분 -->
    <div class="jb-id">
      <div id="id">
        <%=rs.getString("cveid") + "<br>"%></div>
      <div class="jb-des">
        <c:out value="${descriptionKR}" escapeXml="true">
        </c:out>
        <br>
      </div>
    </div>


    <div class="jb-text1">
      <!-- alert함수 이스케이프 -->
      <div id="jb-desKR">
        <c:out value="${description}" escapeXml="true">
        </c:out>
        <br>
      </div>
      <br>
      <div id="p-date"><%="발행시기 : " + rs.getString("publish_date") + "&nbsp&nbsp&nbsp&nbsp&nbsp"%></div>
      <div id="u-date"><%="업데이트 시기 : " + rs.getString("update_date")%></div>
      <br>
      <div id="score">
        <br>
        <h2>[ V2 ]</h2>
        <h3>Score</h3>
        <meter min="0.0" max="10.0" low="3.5" high="7.0" optimum="0.0" value="<%=rs.getString("cvss_v2_score")%>"></meter>
        <h3><%=cvss_v2_score%></h3>
        <!-- 변경됨 -->
        <h3><%="Level:"%></h3>
        <h3 style="color: <%=color_v2%>"><%=cvss_v2_lv%></h3>
      </div>
      <div id="score">
        <h2>[ V3 ]</h2>
        <h3>Score</h3>
        <meter min="0.0" max="10.0" low="3.5" high="7.0" optimum="0.0" value="<%=rs.getString("cvss_v3_score")%>"></meter>
        <h3><%=cvss_v3_score%></h3>
        <!-- 변경됨 -->
        <h3><%="Level:"%></h3>
        <h3 style="color: <%=color_v3%>"><%=cvss_v3_lv%></h3>
        <h3><%="Version : " + cvss_v3_version%></h3>
      </div>
    </div>

    <%
    }
    } catch (Exception e) {
    out.println("Failure!!! : " + e);
    e.printStackTrace();
    }
    %>

    <!-- 페이지 테이블-->

    <div class="paging">
      <%
      if (search != null) {
      %>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=1&search=<%=request.getParameter("search")%>">[맨뒤로]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=prev_pageno%>&search=<%=request.getParameter("search")%>">[이전]</a>
      &nbsp;&nbsp;
      <%
      } else if (check != null) {
      %>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=1&check=<%=request.getParameter("check")%>">[맨뒤로]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=prev_pageno%>&search=<%=request.getParameter("search")%>">[이전]</a>
      &nbsp;&nbsp;
      <%
      }

      else {
      %>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=1">[맨뒤로]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=prev_pageno%>">[이전]</a>
      &nbsp;&nbsp;
      <%
      }
      %>
      <%
      for (int i = page_sno; i <= page_eno; i++) {
        if (search != null) {
      %>

      <a href="cve_information.jsp?pageno=<%=i%>&search=<%=request.getParameter("search")%>">
        <%
        } else if (check != null) {
        %>
        <a href="cve_information.jsp?pageno=<%=i%>&check=<%=request.getParameter("check")%>">
          <%
          } else {
          %>
          <a href="cve_information.jsp?pageno=<%=i%>">
            <%
            }
            if (pageno == i) {
            %>
            [<%=i%>]
            <%
            } else {
            %>
            <%=i%>
            <%
            }
            %>
          </a>
        </a>
      </a>
      <%
      if (i < page_eno) {
      %>
      ,
      <%
      }
      }
      %>
      <%
      /* 검색어 값이 존재 할 시 페이징 처리 */
      if (search != null) {
      %>
      &nbsp;&nbsp;
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=next_pageno%>&search=<%=request.getParameter("search")%>">[다음]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=total_page%>&search=<%=request.getParameter("search")%>">[맨앞으로]</a>
      <%
      /* 체크 값이 존재할 시 페이징 처리 */
      } else if (check != null) {
      %>
      &nbsp;&nbsp;
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=next_pageno%>&check=<%=request.getParameter("check")%>">[다음]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=total_page%>&check=<%=request.getParameter("check")%>">[맨앞으로]</a>
      <%
      }
      /* 검색어, 체크 값 없을시 페이징 처리  */
      else {
      %>
      &nbsp;&nbsp;
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=next_pageno%>">[다음]</a>
      <a style="font-weight: bolder; color: blue;" href="cve_information.jsp?pageno=<%=total_page%>">[맨앞으로]</a>
      <%
      }
      %>
    </div>

  </main>
  <footer>
    <!-- 하단부 -->
    <p style="text-align: center; color: white; padding: 5rem 0 0 0;">@에스큐브아이</p>
  </footer>
</body>
</html>