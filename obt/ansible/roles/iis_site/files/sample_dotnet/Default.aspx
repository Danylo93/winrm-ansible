<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Milessis ASP.NET Sample</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #2c3e50; }
        .meta { color: #555; }
    </style>
    <!-- Simple Web Forms page without code-behind -->
    <script runat="server">
        protected string Host => Request.Url.Host;
        protected string UtcNow => System.DateTime.UtcNow.ToString("u");
    </script>
  </head>
  <body>
    <h1>ASP.NET Web Forms OK</h1>
    <p>Site: <%= Host %></p>
    <p class="meta">UTC: <%= UtcNow %></p>
  </body>
</html>

