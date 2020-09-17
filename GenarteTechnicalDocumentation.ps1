#This is a Powershell script
#This script genrates the Technical Documentation from Blue Prism Process


 

[CmdletBinding(SupportsShouldProcess)]

Param(

   [Parameter(Mandatory=$False, Position=0, HelpMessage="Blue Prism Process Name")]

   [string]$ProcessName,

   [Parameter(Mandatory=$False, Position=1, HelpMessage="Blue Prism appvve as /appvve:B1956CFC-15FC...")]

   [string]$appvve,

   [Parameter(Mandatory=$False, Position=2, HelpMessage="Blue Prism Connection")]

   [string]$dbconname,

   [Parameter(Mandatory=$False, Position=3, HelpMessage="Blue Prism Username")]

   [string]$User

)

 

$referencingassemblies = ("C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.XML.dll","C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Core.dll","C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.IO.Compression.FileSystem.dll")

 

$Source = @"

using System;

using System.Collections.Generic;

using System.Xml;

using System.Linq;

 

namespace XMLReader

{

   public static class Program

    {

 

        public class Stage

        {

            public string id;

            public string name;

            public string desc;

            public string precon;

            public string postcon;

        }

 

 

        public static class XMLToHtml {

 

       

            public static string ParseXMLToHTML(string XMLPath, object[] actionList, bool allItems = false)

            {

           

                String path = XMLPath;

                var Elements = new List<String>();

 

                List<Stage> stageList = new List<Stage>();

                string objectName = string.Empty;

                var actions = new HashSet<string>();               

                foreach (var o in actionList)

                {

                    actions.Add(Convert.ToString(o));

                }

 

                XmlDocument xdoc = new XmlDocument();

                xdoc.Load(path);

 

 

                var rootelement = xdoc.DocumentElement;

 

                objectName = rootelement.Attributes["name"].Value.ToString();

 

                foreach (XmlNode item in rootelement.ChildNodes)

                {

                    if (item.Name == "stage" && item.Attributes["type"].Value == "SubSheetInfo")

                    {

                        string stageName = item.Attributes["name"].Value;

                        if (!allItems && !actions.Contains(stageName))

                        {

                            continue;

                        }

                        string subsheetid = String.Empty;

                        string desc = String.Empty;

                        foreach (XmlNode childItem in item.ChildNodes)

                        {

 

                            if (childItem.Name == "subsheetid")

                                subsheetid = childItem.InnerText;

 

                            if (childItem.Name == "narrative")

                                desc = childItem.InnerText;

                        }

 

                        var stage = new Stage();

                        stage.id = subsheetid;

                        stage.name = stageName;

                        stage.desc = desc;

                        stageList.Add(stage);

 

                    }

                }

 

 

 

                foreach (Stage stage in stageList)

                {

                    foreach (XmlNode item in rootelement.ChildNodes)

                    {

                        if (item.Name == "stage" && item.Attributes["type"].Value == "Start")

                        {

                            bool found = false;

                            //check for ID

                            foreach (XmlNode childItem in item.ChildNodes)

                            {

                                if (childItem.Name == "subsheetid" && childItem.InnerText == stage.id)

                                {

                                    found = true;

                                    continue;

                                }

                            }

 

                            //check if pre/postconditions exists

                            foreach (XmlNode childItem in item.ChildNodes)

                            {

                                if (childItem.Name == "preconditions" && found && childItem.ChildNodes.Count > 0)

                                    stage.precon = string.Join("; ", childItem.ChildNodes.OfType<XmlNode>().Select(c => c.Attributes["narrative"] == null ? null : c.Attributes["narrative"].Value.ToString()).Where(s => !string.IsNullOrWhiteSpace(s)));

 

                                if (childItem.Name == "postconditions" && found && childItem.ChildNodes.Count > 0)

                                    stage.postcon = string.Join("; ", childItem.ChildNodes.OfType<XmlNode>().Select(c => c.Attributes["narrative"] == null ? null : c.Attributes["narrative"].Value.ToString()).Where(s => !string.IsNullOrWhiteSpace(s)));

                            }

                        }

                    }

               }

 

                string html = string.Empty;

 

                html += String.Format("<h3> ") + objectName + Environment.NewLine + String.Format("</h3> ") + Environment.NewLine;

 

                foreach (var stage in stageList)

                {

                    html += String.Format("<h4> ") + String.Format("&nbsp;&nbsp;&nbsp;&nbsp;{0}", stage.name) + String.Format("</h4> ") + Environment.NewLine;

 

                      //split developer from description

                    if(stage.desc.Contains("Main Developer:"))

                         stage.desc = stage.desc.Replace("Main Developer:", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Main Developer:</b>");

                    if(stage.desc.Contains("Other Developers:"))

                         stage.desc = stage.desc.Replace("Other Developers:", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Other Developers:</b>");

                        

                    html += String.Format("") + String.Format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Description:</b>      {0}<br>", stage.desc) + String.Format("") + Environment.NewLine;

                    html += String.Format("") + String.Format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Preconditions:</b>    {0}<br>", stage.precon) + String.Format("") + Environment.NewLine;

                    html += String.Format("") + String.Format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Postconditions:</b>    {0}<br>", stage.postcon) + String.Format("") + Environment.NewLine;

 

                }

               

                return html;

               

            }

            public static string ParseXMLToMarkdown(string XMLPath, object[] actionList, bool allItems = false)

            {

 

                String path = XMLPath;

                var Elements = new List<String>();

 

                List<Stage> stageList = new List<Stage>();

                string objectName = string.Empty;

                var actions = new HashSet<string>();

                foreach (var o in actionList)

                {

                    actions.Add(Convert.ToString(o));

                }

 

                XmlDocument xdoc = new XmlDocument();

                xdoc.Load(path);

 

 

                var rootelement = xdoc.DocumentElement;

 

                objectName = rootelement.Attributes["name"].Value.ToString();

 

                foreach (XmlNode item in rootelement.ChildNodes)

                {

                    if (item.Name == "stage" && item.Attributes["type"].Value == "SubSheetInfo")

                    {

                        string stageName = item.Attributes["name"].Value;

                        if (!allItems && !actions.Contains(stageName))

                        {

                            continue;

                        }

                        string subsheetid = String.Empty;

                        string desc = String.Empty;

                        foreach (XmlNode childItem in item.ChildNodes)

                        {

 

                            if (childItem.Name == "subsheetid")

                                subsheetid = childItem.InnerText;

 

                            if (childItem.Name == "narrative")

                                desc = childItem.InnerText;

                        }

 

                        var stage = new Stage();

                        stage.id = subsheetid;

                        stage.name = stageName;

                        stage.desc = desc;

                        stageList.Add(stage);

 

                    }

                }

 

 

 

                foreach (Stage stage in stageList)

                {

                    foreach (XmlNode item in rootelement.ChildNodes)

                    {

                        if (item.Name == "stage" && item.Attributes["type"].Value == "Start")

                        {

                            bool found = false;

                            //check for ID

                            foreach (XmlNode childItem in item.ChildNodes)

                            {

                                if (childItem.Name == "subsheetid" && childItem.InnerText == stage.id)

                                {

                                    found = true;

                                    continue;

 

                                }

                            }

 

                            //check if pre/postconditions exists

                            foreach (XmlNode childItem in item.ChildNodes)

                            {

                                if (childItem.Name == "preconditions" && found && childItem.ChildNodes.Count > 0)

                                    stage.precon = string.Join("; ", childItem.ChildNodes.OfType<XmlNode>().Select(c => c.Attributes["narrative"] == null ? string.Empty : c.Attributes["narrative"].Value.ToString()).Where(s => !string.IsNullOrWhiteSpace(s)));

 

                                if (childItem.Name == "postconditions" && found && childItem.ChildNodes.Count > 0)

                                    stage.postcon = string.Join("; ", childItem.ChildNodes.OfType<XmlNode>().Select(c => c.Attributes["narrative"] == null ? string.Empty : c.Attributes["narrative"].Value.ToString()).Where(s => !string.IsNullOrWhiteSpace(s)));

                            }

                        }

                    }

                }

 

                string html = string.Empty;

 

                html += String.Format("h2. ") + objectName + Environment.NewLine;

 

                foreach (var stage in stageList)

                {

                    html += String.Format("h3. ") + String.Format("{0}", stage.name) + Environment.NewLine;

                    //split developer from description

                    if (stage.desc.Contains("Main Developer:"))

                        stage.desc = stage.desc.Replace("Main Developer:", Environment.NewLine + "*Main Developer:* ");

                    if (stage.desc.Contains("Other Developers:"))

                        stage.desc = stage.desc.Replace("Other Developers:", "*Other Developers:*");

                    html += String.Format("*Description:* {0}", stage.desc) + Environment.NewLine + Environment.NewLine;

                    html += String.Format("*Preconditions:* {0}", stage.precon) + Environment.NewLine;

                    html += String.Format("*Postconditions:* {0}", stage.postcon) + Environment.NewLine;

 

                }

 

                return html;

 

            }

 

            public static string AddHTMLTags(string htmlString)

            {

                string html = string.Empty;

 

                html += String.Format("<!DOCTYPE html>") + Environment.NewLine;

                html += String.Format("<html >") + Environment.NewLine;

                html += String.Format("<body > ") + Environment.NewLine;

                html += htmlString;

                html += String.Format("</body > ") + Environment.NewLine;

                html += String.Format("</html >") + Environment.NewLine;

 

                return html;

 

 

 

            }

 

            public static void WriteHtmlFile(string path, string fileName, string htmlString)

            {

 

                try

                {

                    System.IO.File.WriteAllText(path + fileName + ".html", htmlString, System.Text.Encoding.Unicode);

                }

                catch (Exception)

                {

 

                    throw;

                }

 

 

            }

            public static void WriteMDFile(string path, string fileName, string htmlString)

            {

 

                try

                {

                    System.IO.File.WriteAllText(path + fileName + ".txt", htmlString, System.Text.Encoding.Unicode);

                }

                catch (Exception)

                {

 

                    throw;

                }

 

 

            }

 

        }

       

        public static void Main(string[] args)

        {

            string HtmlTemp = string.Empty;

 

            foreach (string Path in args)

            {

                HtmlTemp += XMLToHtml.ParseXMLToHTML(Path, new object[]{});

            }

            string Html = string.Empty;

            Html = XMLToHtml.AddHTMLTags(HtmlTemp);

            XMLToHtml.WriteHtmlFile(@"H:\", "Test", Html);

 

        }

    }

}
