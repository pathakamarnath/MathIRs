<%--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at
  
  http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--%>
<%@ page 
  session="false"
  contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"

  import="java.io.*"
  import="java.util.*"
  import="java.net.*"
  

  import="org.apache.nutch.html.Entities"
  import="org.apache.nutch.metadata.Nutch"
  import="org.apache.nutch.searcher.*"
  import="org.apache.nutch.plugin.*"
  import="org.apache.nutch.clustering.*"
  import="org.apache.hadoop.conf.*"
  import="org.apache.nutch.util.NutchConfiguration"

%>

<style> 
.flex-container {
    display: -webkit-flex;
    display: flex;  
    -webkit-flex-flow: row wrap;
    flex-flow: row wrap;
    text-align: right;
}

.flex-container > * {
    padding: 15px;
    -webkit-flex: 1 100%;
    flex: 1 100%;
}

.article {
    text-align: left;
}

header {background: orange;color:black;top: 0;
    right: 0;}
footer {background: white;color:black;position:absolute;
   bottom:0px;    
width:100%;
     border-top:2px solid;
    border-top-width:100%;   
   
   }

    
.nav {background:#eee;}

.nav ul {
    list-style-type: none;
    padding: 0;
}
.nav ul a {
    text-decoration: none;
}

@media all and (min-width: 768px) {
    .nav {text-align:left;-webkit-flex: 1 auto;flex:1 auto;-webkit-order:1;order:1;}
    .article {-webkit-flex:5 0px;flex:5 0px;-webkit-order:2;order:2;}
    footer {-webkit-order:3;order:3;}
}
</style>

<%
	/*
	*All Path Declarations	
	*/
	String path_of_tex_query= "/home/workstation/apache-tomcat-6.0.45/texquery.txt";
	String path_of_mathml_query= "/home/workstation/apache-tomcat-6.0.45/texquery_MathToWeb_000.txt";
	String conversion_command="java -jar mathtoweb.jar texquery.txt";
	String link_to_home_page=" http://localhost:8080/MathIRs/index.html";
	String link_to_About_Us="http://localhost:8080/MathIRs/AboutUs.jsp";
	String link_to_Sample_queries=" http://localhost:8080/MathIRs/SampleQueries.html ";
	String link_to_feedback=" http://localhost:8080/MathIRs/Feedback.jsp";
	String link_to_help="  http://localhost:8080/MathIRs/Help.jsp";
	String dst_logo="http://localhost:8080/MathIRs/dstserb.png";
	String nitmz_logo="http://localhost:8080/MathIRs/nitmz.png";
	String nutch_logo="http://localhost:8080/MathIRs/nutch.gif";
%>

<div class="flex-container">

        
        
        
       
<header>
<table>
<tr>
<td width="75%"> <b>MathIRs: Math Information Retrieval System</b> </td>

<td style="padding-right: 5px" align="center"><a href="<%=link_to_home_page%>">Home Page   </a></td>

<td style="padding-right: 5px" align="center"><a href="<%=link_to_About_Us%>">About Us   </a></td>

<td style="padding-right: 12px" align="center"><a href="<%=link_to_Sample_queries%>">SampleQueries   </a></td>

<td style="padding-right: 12px" align="center"><a href=" <%=link_to_feedback%>">Feedback   </a></td>

<td align="center"><a href="<%=link_to_help%>">Help</a></td>
</tr>
</table>
</header>

<footer>

	<table align="center">
	<tr><td align="center">        <img src=" <%=dst_logo%>" height="30%" width="30%"/> </td>
	    <td align="center">        <img src=" <%=nitmz_logo%>" height="30%" width="30%"/> </td>
	    <td align="center">        <img src=" <%=nutch_logo%>" height="30%" width="30%"/> </td>
	</tr>
	<tr><td align="center">        Sponsored by DST-SERB </td>
	    <td align="center">        Developed by NIT Mizoram</td>
	    <td align="center">        Powered by NUTCH </td>
	</tr>
	</table>   
</footer>

</div>

<%
	
  Configuration nutchConf = NutchConfiguration.get(application);
  
  /**
   * Number of hits to retrieve and cluster if clustering extension is available
   * and clustering is on. By default, 100. Configurable via nutch-conf.xml.
   */
  int HITS_TO_CLUSTER = 
    nutchConf.getInt("extension.clustering.hits-to-cluster", 100);

  /**
   * An instance of the clustering extension, if available.
   */
  OnlineClusterer clusterer = null;
  try {
    clusterer = new OnlineClustererFactory(nutchConf).getOnlineClusterer();
  } catch (PluginRuntimeException e) {
    // NOTE: Dawid Weiss
    // should we ignore plugin exceptions, or rethrow it? Rethrowing
    // it effectively prevents the servlet class from being loaded into
    // the JVM
  }
  
%>



<%--
<%@ include file="./refine-query-init.jsp" %>

--%>


<%
  
  NutchBean bean = NutchBean.get(application, nutchConf);
  // set the character encoding to use when interpreting request values 
  request.setCharacterEncoding("UTF-8");

  bean.LOG.info("query request from " + request.getRemoteAddr());

  FileInputStream fis = new FileInputStream("/home/workstation/MathIRs/All Evaluations/Eval5/queryset5.0.txt");            
  BufferedReader br3 = new BufferedReader(new InputStreamReader(fis));                        
  FileOutputStream fos = new FileOutputStream("/home/workstation/MathIRs/All Evaluations/Eval5/resultor5.0.txt");           
  PrintWriter pw3 = new PrintWriter(new OutputStreamWriter(fos));
 
  HashSet<String> sets=new HashSet<String>();

  // get query from request
  String queryString = request.getParameter("query"); 
  

%> 

 <%  
    
  //out.println(queryString);
  if (queryString == null)
    queryString = "";
  String htmlQueryString = Entities.encode(queryString);
  
  // a flag to make the code cleaner a bit.
  boolean clusteringAvailable = (clusterer != null);

  String clustering = "";
  if (clusteringAvailable && "yes".equals(request.getParameter("clustering")))
    clustering = "yes";

  int start = 0;          // first hit to display
  String startString = request.getParameter("start");
  if (startString != null)
    start = Integer.parseInt(startString);

  int hitsPerPage = 40;          // number of hits to display
  String hitsString = request.getParameter("hitsPerPage");
  if (hitsString != null)
    hitsPerPage = Integer.parseInt(hitsString);

  int hitsPerSite = 40;                            // max hits per site
String hitsPerSiteString = request.getParameter("hitsPerSite");
  if (hitsPerSiteString != null)
    hitsPerSite = Integer.parseInt(hitsPerSiteString);

  String sort = request.getParameter("sort");
  boolean reverse =
    sort!=null && "true".equals(request.getParameter("reverse"));

  String params = "&hitsPerPage="+hitsPerPage
     +(sort==null ? "" : "&sort="+sort+(reverse?"&reverse=true":""));

  int hitsToCluster = HITS_TO_CLUSTER;            // number of hits to cluster

  // get the lang from request
  String queryLang = request.getParameter("lang");
  
  
  
  
  if (queryLang == null) { queryLang = ""; }
  
  
  
  
  
  
  
  
  Query query = Query.parse(queryString, queryLang, nutchConf);
  
  bean.LOG.info("query: " + queryString);
  bean.LOG.info("lang: " + queryLang);

  String language =
    ResourceBundle.getBundle("org.nutch.jsp.search", request.getLocale())
    .getLocale().getLanguage();
  String requestURI = HttpUtils.getRequestURL(request).toString();
  String base = requestURI.substring(0, requestURI.lastIndexOf('/'));
  String rss = "../opensearch?query="+htmlQueryString
    +"&hitsPerSite="+hitsPerSite+"&lang="+queryLang+params;
%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
  // To prevent the character encoding declared with 'contentType' page
  // directive from being overriden by JSTL (apache i18n), we freeze it
  // by flushing the output buffer. 
  // see http://java.sun.com/developer/technicalArticles/Intl/MultilingualJSP/
  out.flush();
%>
<%@ taglib uri="http://jakarta.apache.org/taglibs/i18n" prefix="i18n" %>
<i18n:bundle baseName="org.nutch.jsp.search"/>
<html lang="<%= language %>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<head>
<title>Nutch: <i18n:message key="title"/></title>
<link rel="icon" href="img/favicon.ico" type="image/x-icon"/>
<link rel="shortcut icon" href="img/favicon.ico" type="image/x-icon"/>
<link rel="alternate" type="application/rss+xml" title="RSS" href="<%=rss%>"/>
<jsp:include page="include/style.html"/>
<base href="<%= base  + "/" + language %>/">
<script type="text/javascript">
<!--
function queryfocus() { document.search.query.focus(); }
// -->

</script>

</head>


<%                                                          
int q1=0;      
                                             
String line4 = "";                                               
while((line4=br3.readLine())!=null){   // start of while loop for each querystring present in query file                                    
    String[] strr=line4.split("\t");                                       
    q1=Integer.parseInt(strr[0]);                                       
    String CompleteString=strr[1]; 
    String[] arrs = CompleteString.split(" "); 
 //for ( String sss : arrs)  // start of for loop for each word in the querystring
 //{
    
    queryString=CompleteString;                                          
    String urls = "";                                           
    //int length_need=Integer.parseInt(str[2]);    
    String line2=" ";
	String cs2=" ";

	PrintWriter pw2=new PrintWriter(path_of_tex_query);
	pw2.write(queryString);   
	pw2.flush();
	File f=new File(path_of_mathml_query);
	f.delete();
	Runtime.getRuntime().exec(conversion_command);
	Thread.sleep(3000);
	BufferedReader br2=new BufferedReader(new FileReader(path_of_mathml_query));
	line2=br2.readLine();

	while(line2!=null)
	{
		cs2+=line2;
	
		line2=br2.readLine();
	}

	queryString=cs2;                           
%>    
  <% String textinbold="<b>The query string entered by you is: </b>";
  out.print(textinbold);
out.println(cs2);
for ( String sss : arrs) //start of for loop for each word in the querystring
{
	queryString=sss;
%>
<%                                                       
     htmlQueryString = Entities.encode(queryString);                           
     query = Query.parse(queryString, queryLang, nutchConf);                       
     //bean.LOG.info("query: " + queryString);                               
     //bean.LOG.info("lang: " + queryLang);                                   
     rss = "../opensearch?query="+htmlQueryString+"&hitsPerSite="+hitsPerSite+"&lang="+queryLang+params;   
     out.flush();                                               
    %>    









<br>
<body onLoad="queryfocus();">
 <form name="search" action="../search.jsp" method="get">
 <input name="query" size=44 value="<%=htmlQueryString%>">
 <input type="hidden" name="hitsPerPage" value="<%=hitsPerPage%>">
 <input type="hidden" name="lang" value="<%=language%>">
 <input type="submit" value="<i18n:message key="search"/>">
 <% if (clusteringAvailable) { %>
   <input id="clustbox" type="checkbox" name="clustering" value="yes" <% if (clustering.equals("yes")) { %>CHECKED<% } %>>
    <label for="clustbox"><i18n:message key="clustering"/></label>
 <% } %>
 <a href="help.html">help</a>
 </form>
 
<%--
// Uncomment this to enable query refinement.
// Do the same to "refine-query-init.jsp" above.
<%@ include file="./refine-query.jsp" %>
--%>

<%
   // how many hits to retrieve? if clustering is on and available,
   // take "hitsToCluster", otherwise just get hitsPerPage
   int hitsToRetrieve = (clusteringAvailable && clustering.equals("yes") ? hitsToCluster : hitsPerPage);

   if (clusteringAvailable && clustering.equals("yes")) {
     bean.LOG.info("Clustering is on, hits to retrieve: " + hitsToRetrieve);
   }

   // perform query
    // NOTE by Dawid Weiss:
    // The 'clustering' window actually moves with the start
    // position.... this is good, bad?... ugly?....
   Hits hits;
   try{
     hits = bean.search(query, start + hitsToRetrieve, hitsPerSite, "site",
                        sort, reverse);
  //search(Query, int, int, String, String, boolean) in the type NutchBean
   } catch (IOException e){
     hits = new Hits(0,new Hit[0]);	
   }
   int end = (int)Math.min(hits.getLength(), start + hitsPerPage);
   int length = end-start;
   int realEnd = (int)Math.min(hits.getLength(), start + hitsToRetrieve);

   Hit[] show = hits.getHits(start, realEnd-start);
   HitDetails[] details = bean.getDetails(show);
   Summary[] summaries = bean.getSummary(details, query);
   bean.LOG.info("total hits: " + hits.getTotal());
%>

<hr>

<i18n:message key="hits">
  <i18n:messageArg value="<%=new Long((end==0)?0:(start+1))%>"/>
  <i18n:messageArg value="<%=new Long(end)%>"/>
  <i18n:messageArg value="<%=new Long(hits.getTotal())%>"/>
</i18n:message>

<%
// be responsive
out.flush();
%>

<br><br>

<% if (clustering.equals("yes") && length != 0) { %>
<table border=0 cellspacing="3" cellpadding="0">

<tr>

<td valign="top">

<% } %>


<% 
  for (int i = 0; i < length; i++) {      // display the hits
   int flagcheck=0;
    Hit hit = show[i];
    HitDetails detail = details[i];
    String title = detail.getValue("title");
    String url = detail.getValue("url");
    String id = "idx=" + hit.getIndexNo() + "&id=" + hit.getIndexDocNo();
    String summary = summaries[i].toHtml(true);
    String caching = detail.getValue("cache");
   
    boolean showSummary = true;
    boolean showCached = true;
    if (caching != null) {
      showSummary = !caching.equals(Nutch.CACHING_FORBIDDEN_ALL);
      showCached = !caching.equals(Nutch.CACHING_FORBIDDEN_NONE);
    }

    if (title == null || title.equals("")) {      // use url for docs w/o title
      title = url;
    }
   
     hitsPerSiteString = request.getParameter("hitsPerSite");
  if (hitsPerSiteString != null)
    hitsPerSite = Integer.parseInt(hitsPerSiteString);
    
    
    
    
 
  	  String url_no = url.replace(".xml","");
        String[] tokens = url.split("[\\\\|/]");
		String filename = tokens[tokens.length - 1];
       	url_no = filename.replace(".xhtml","");
       
   	if (!sets.contains(q1+"\t"+"Q0"+"\t"+url_no+"\t"+"1"+"\t"+hitsPerSite+"\t"+"demo"))
      {
        sets.add(q1+"\t"+"Q0"+"\t"+url_no+"\t"+"1"+"\t"+hitsPerSite+"\t"+"demo");
         pw3.println(q1+"\t"+"Q0"+"\t"+url_no+"\t"+"1"+"\t"+hitsPerSite+"\t"+"demo");   
      }
   
         
   
   
      	
      		
        
        
        
        
    %>
    <b><a href="<%=url%>"><%=Entities.encode(title)%></a></b>
    <%@ include file="more.jsp" %>
    <% if (!"".equals(summary) && showSummary) { %>
    <br><%=summary%>
    <% } %>
    <br>
    <span class="url"><%=Entities.encode(url)%></span>
    <%
      if (showCached) {
        %>(<a href="../cached.jsp?<%=id%>"><i18n:message key="cached"/></a>) <%
    }
    %>
    (<a href="../explain.jsp?<%=id%>&query=<%=URLEncoder.encode(queryString, "UTF-8")%>&lang=<%=queryLang%>"><i18n:message key="explain"/></a>)
    (<a href="../anchors.jsp?<%=id%>"><i18n:message key="anchors"/></a>)
    <% if (hit.moreFromDupExcluded()) {
    String more =
    "query="+URLEncoder.encode("site:"+hit.getDedupValue()+" "+queryString, "UTF8")
    +params+"&hitsPerSite="+0
    +"&lang="+queryLang
    +"&clustering="+clustering;%>
    (<a href="../search.jsp?<%=more%>"><i18n:message key="moreFrom"/>
     <%=hit.getDedupValue()%></a>)
    <% } %>
    <br><br>
<% } %>






<% if (clustering.equals("yes") && length != 0) { %>

</td>

<!-- clusters -->
<td style="border-right: 1px dotted gray;" />&#160;</td>
<td align="left" valign="top" width="25%">
<%@ include file="cluster.jsp" %>
</td>

</tr>
</table>

<% } %>

<%

if ((hits.totalIsExact() && end < hits.getTotal()) // more hits to show
    || (!hits.totalIsExact() && (hits.getLength() > start+hitsPerPage))) {
%>
    <form name="next" action="../search.jsp" method="get">
    <input type="hidden" name="query" value="<%=htmlQueryString%>">
    <input type="hidden" name="lang" value="<%=queryLang%>">
    <input type="hidden" name="start" value="<%=end%>">
    <input type="hidden" name="hitsPerPage" value="<%=hitsPerPage%>">
    <input type="hidden" name="hitsPerSite" value="<%=hitsPerSite%>">
    <input type="hidden" name="clustering" value="<%=clustering%>">
    <input type="submit" value="<i18n:message key="next"/>">
<% if (sort != null) { %>
    <input type="hidden" name="sort" value="<%=sort%>">
    <input type="hidden" name="reverse" value="<%=reverse%>">
<% } %>
    </form>
<%
    }  //end of for

if ((!hits.totalIsExact() && (hits.getLength() <= start+hitsPerPage))) {
%>
    <form name="showAllHits" action="../search.jsp" method="get">
    <input type="hidden" name="query" value="<%=htmlQueryString%>">
    <input type="hidden" name="lang" value="<%=queryLang%>">
    <input type="hidden" name="hitsPerPage" value="<%=hitsPerPage%>">
    <input type="hidden" name="hitsPerSite" value="0">
    <input type="hidden" name="clustering" value="<%=clustering%>">
    <input type="submit" value="<i18n:message key="showAllHits"/>">
<% if (sort != null) { %>
    <input type="hidden" name="sort" value="<%=sort%>">
    <input type="hidden" name="reverse" value="<%=reverse%>">
<% } %>
    </form>
<%
    }
     pw2.close();  
     br2.close(); 
     }//end of for loop for each word in the querystring
     
    }// end of while for each querystring in query file
   
    pw3.close();                               
    fos.close();                               
                                    
    fis.close();  
   
    
%>




</body>
</html>
