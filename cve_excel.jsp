<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
%>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@page import="page.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<%!
  Connection conn = null; //DB연결
  PreparedStatement ps;
  ResultSet rs; //쿼리생성
  SettingSQL p = new SettingSQL();
%>
<%
String sql = p.getSql();
response.setHeader("Content-Disposition", "attachment; filename=cve_information.xls"); 
response.setHeader("Content-Description", "JSP Generated Data"); 
response.setContentType("application/vnd.ms-excel");   

%>
<!DOCTYPE html>
<html>
<head>
<title>엑셀파일다운로드</title>
<meta charset="UTF-8">
</head>
<body>

	<table border=1>
		<!-- border=1은 필수 excel 셀의 테두리가 생기게함 -->
		<tr bgcolor=#CACACA>
			<th>CVE-ID</th>
			<th>타입</th>
			<th>설명</th>
			<th>CVE Type</th>
			<th>CVE등록일자</th>
			<th>CVE최근수정일자</th>
			<th>CVSS v2점수</th>
			<th>CVSS v3점수</th>
			<th>위험도</th>
		</tr>

		<%
    Connection conn=null;
    PreparedStatement ps;
             ResultSet rs;
              Statement stmt;
   try{
       if(sql ==null){
    	   sql = "SELECT * FROM cve_information WHERE cvss_v2_score IS NOT NULL AND cvss_v3_score IS NOT NULL AND descriptionKR LIKE '예약된' AND cveid LIKE 'CVE-2022%' ORDER BY cveid DESC limit 10"; 
       }
       Context init = new InitialContext();
       DataSource ds = (DataSource) init.lookup("java:comp/env/jdbc/cveDB");
       conn = ds.getConnection();
       stmt = conn.createStatement();
       ps = conn.prepareStatement(sql);
       rs = ps.executeQuery();

       while (rs.next()) {
            String cvss_v2_score = rs.getString("cvss_v2_score"); 
            String cvss_v3_score = rs.getString("cvss_v3_score"); 
            String cvss_v2_lv = rs.getString("cvss_v2_lv"); 
            String cvss_v3_lv = rs.getString("cvss_v3_lv"); 
            String publish_date = rs.getString("publish_date");
            String update_date = rs.getString("update_date");
            String description = rs.getString("description") ;
            String descriptionKR = rs.getString("descriptionKR"); 
            
           /*  publish_date = publish_date.replace("T", "\t");
            publish_date = publish_date.substring(0, 19);
            
            update_date = update_date.replace("T", "\t");
            update_date = update_date.substring(0, 18); */

      
          
            if (cvss_v2_score.equals("none")) { 
              cvss_v2_score = " ";
        
            }
            if (cvss_v3_score.equals("none")) { 
              cvss_v3_score = " ";
             
            }
            if (cvss_v2_lv.equals("none")) { 
              cvss_v2_lv = " ";
             
            }
            if (cvss_v3_lv.equals("none")) { 
              cvss_v3_lv = " ";
           
            }
            if(!cvss_v2_lv.equals("none")&&cvss_v3_lv.equals("none")){
              cvss_v3_lv = cvss_v2_lv;
            }
            String script = description + "\n\n[한글번역]\n" + descriptionKR;
            script = script.replaceAll("\\n", "<br style='mso-data-placement:same-cell;'>");

%>
		<tr>

			<td><%=rs.getString("cveid")%></td>
			<td></td>
			<td style="white-space: pre-line;">
				<%=script%></td>
			<td>cve</td>
			<td><%=publish_date%></td>
			<td><%=update_date%></td>
			<td><%=cvss_v2_score%></td>
			<td><%=cvss_v3_score%></td>
			<td><%=cvss_v3_lv%></td>
		</tr>
		<% 
}
   }catch(Exception e){
       out.println(e);
       e.printStackTrace();
   }

  %>

	</table>

</body>
</html>