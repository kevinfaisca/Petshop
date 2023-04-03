<%
	vstr_local = "../"
%>

<style>
	.btn_transferirProfile{
		padding: 10px;
		border-radius: 7px;
		border: none;
		cursor: pointer;
	}
	.btn_fecharProfile {
		padding: 10px;
		border-radius: 7px;
		border: none;
		cursor: pointer;
	}
</style>

<title>Upload de Arquivos</title>

<!-- Importante p/ responsividade -->
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />

<!-- #include file="../includes/functions.asp" -->

<% 
	Response.Expires		= -1
	Server.ScriptTimeout	= 12000
	session.Timeout			= 1200
	vstr_local				= request("ds_local")
	vstr_campo				= request("campo")
	vstr_nomeInput          = request("pstr_nomeInput")
	
	Dim uploadsDirVar
	
	if vstr_local			= "documentosUsuario" then
        uploadsDirVar		= cstr_caminhoFisico & "arquivos\documentosUsuario\"
		vstr_tipoArquivo	= "TODOS"

	else
		uploadsDirVar		= cstr_caminhoFisico & "arquivos\geral\"
		vstr_tipoArquivo	= "TODOS"
	end if
	
%>

<!-- #include file="freeaspupload.asp" -->
<%
	function OutputForm()
%>
		<form name="frmSend" method="POST" enctype="multipart/form-data" action="profile.asp?ds_local=<%=vstr_local%>&pstr_nomeInput=<%=vstr_nomeInput%>&campo=<%=vstr_campo%>&id_empreendimento=<%=vint_idEmpreendimento%>" onSubmit="return onSubmitForm();">
			<table style="width: 100%;" border="0" cellpadding="3" cellspacing="0">
				<tr>
					<td class="subTitulo">Upload de Arquivos</td>
				</tr>
				<tr>
					<td height="10"></td>
				</tr>
				
				<%	If Len(Request.QueryString("pstr_erro"))>0 Then %>
						<tr>
							<td align="center" class="chamada" valign="middle">
								<%=Request.QueryString("pstr_erro")%>
							</td>
						</tr>
				<%	End If %>
				
				<tr>
					<td height="10"></td>
				</tr>
				<tr>
					<td align="center">
						<table border="0" cellpadding="0" cellspacing="0" ID="Table2"> 
                            <%
                                if vstr_local   = "fotoUsuario" or vstr_local   = "fotoUsuarioPB" or vstr_local   = "fotoUsuarioGrande" then   
                            %>

                                    <tr>
								        <td class="textoNegrito">
									        <input name="attach1" type="file" class="text" size="27"><br><br>
                                            <p class="help-block" style="font-size:12px;">(Foto com fundo branco) <b>(somente arquivos jpg, jpeg, png ou pdf)</b></p>
								        </td>
							        </tr>

                            <%
                                else
                            %>
                                    
                                    <tr>
								        <td class="textoNegrito">
									        <input name="attach1" type="file" class="text" size="27"><br><br>
                                            <!--<p class="help-block" style="font-size:12px;"><b>(Somente arquivos em PDF)</b></p>-->
								        </td>
							        </tr>
                            <%
                                end if    
                            %>     
								
							<tr>	
								<td align="center">
									<input type="submit" value="Transferir" class="botao btn_transferirProfile" onclick="javascript: this.value = 'Transferindo - Aguarde';">
									<input type="button" value="Fechar" onclick="javascript: window.close()" class="botao btn_fecharProfile">
									<input type="hidden" name="backurl" value="profile.asp">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</form>
<%
	end function

	function TestEnvironment()
		Dim fso, fileName, testFile, streamTest
		TestEnvironment = ""
		Set fso = Server.CreateObject("Scripting.FileSystemObject")
		if not fso.FolderExists(uploadsDirVar) then
			TestEnvironment = "<B>Folder " & uploadsDirVar & " does not exist.</B><br>The value of your uploadsDirVar is incorrect. Open uploadTester.asp in an editor and change the value of uploadsDirVar to the pathname of a directory with write permissions."
			exit function
		end if
		fileName = uploadsDirVar & "\test.txt"
		on error resume next
		Set testFile = fso.CreateTextFile(fileName, true)
		If Err.Number<>0 then
			TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have write permissions.</B><br>The value of your uploadsDirVar is incorrect. Open uploadTester.asp in an editor and change the value of uploadsDirVar to the pathname of a directory with write permissions."
			exit function
		end if
		Err.Clear
		testFile.Close
		fso.DeleteFile(fileName)
		If Err.Number<>0 then
			TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have delete permissions</B>, although it does have write permissions.<br>Change the permissions for IUSR_<I>computername</I> on this folder."
			exit function
		end if
		Err.Clear
		Set streamTest = Server.CreateObject("ADODB.Stream")
		If Err.Number<>0 then
			TestEnvironment = "<B>The ADODB object <I>Stream</I> is not available in your server.</B><br>Check the Requirements page for information about upgrading your ADODB libraries."
			exit function
		end if
		Set streamTest = Nothing
	end function

	function SaveFiles
		Dim Upload, fileName, fileSize, ks, i, fileKey
		
		Set Upload = New FreeASPUpload
		
		Upload.Save uploadsDirVar,vstr_tipoArquivo,vstr_local,vstr_campo
		
		' If something fails inside the script, but the exception is handled
		If Err.Number<>0 then Exit function

		SaveFiles = ""
		ks = Upload.UploadedFiles.keys
		if (UBound(ks) <> -1) then
			SaveFiles = "File: "
			for each fileKey in Upload.UploadedFiles.keys  
				
				if vstr_local = "documentosUsuario"  then 

                    if instr(Upload.UploadedFiles(fileKey).FileName,".png") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".PNG") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".jpg") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".JPG") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".jpeg") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".JPEG") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".pdf") > 0 or instr(Upload.UploadedFiles(fileKey).FileName,".PDF") > 0 then

                        if len(vstr_nomeInput) > 0 then
                            vstr_arquivoCampo = vstr_nomeInput
                        elseif vstr_local = "" then
					        vstr_arquivoCampo = "txt_arquivo"
				        else
					        vstr_arquivoCampo = "txt_arquivo" & vstr_campo
				        end if
		%>
				        <script language="javascript">
                            window.parent.opener.document.getElementById("<%=vstr_arquivoCampo%>").value = "<%=Upload.UploadedFiles(fileKey).FileName%>";
                        </script>	
		<%	
				        SaveFiles = "<center><table><tr><td align='center' class='chamada'>File: " & Upload.UploadedFiles(fileKey).FileName & "<br>Upload com sucesso!</td></tr></table></center>"
                    else
                        SaveFiles = "Formato não permitido. Favor inserir um novo arquivo, nos formatos jpg, jpeg, png ou pdf." 
                    end if

                else

                    if len(vstr_nomeInput) > 0 then
                        vstr_arquivoCampo = vstr_nomeInput
                    elseif vstr_local = "" then
					    vstr_arquivoCampo = "txt_arquivo"
				    else
					    vstr_arquivoCampo = "txt_arquivo" & vstr_campo
				    end if
		%>
				    <script language="javascript">
                        window.parent.opener.document.getElementById("<%=vstr_arquivoCampo%>").value = "<%=Upload.UploadedFiles(fileKey).FileName%>";
                        window.parent.opener.document.getElementById("<%=vstr_arquivoCampo%>").click();
                    </script>	
		<%	
				    SaveFiles = "<center><table><tr><td align='center' class='chamada'>File: " & Upload.UploadedFiles(fileKey).FileName & "<br>Upload com sucesso!</td></tr></table></center>"

                end if
			next
		else
			SaveFiles = "Formato não permitido. Favor inserir um novo arquivo, nos formatos jpg, jpeg, png ou pdf. "
		end if
	end function
%>

<html>
<head>
	<title></title>

	<script>
		function onSubmitForm() {
			var formDOMObj = document.frmSend;
			if (formDOMObj.attach1.value == "")
				alert("Selecione um arquivo antes de clicar no botão transferir.")
			else
				return true;
			return false;
		}
	</script>
</head>

<body>
<%
	Dim diagnostics
	if Request.ServerVariables("REQUEST_METHOD") <> "POST" then
	    diagnostics = TestEnvironment()
	    if diagnostics <> "" then
	        response.write diagnostics
	    else
	        OutputForm()
	    end if
	else
	   	OutputForm()
	    response.write SaveFiles()
	end if
%>
<br><br>
<br><br>
<!-- Please support this free script by having a link to freeaspupload.net either in this page or somewhere else in your site. 
<div style="border-bottom: #A91905 2px solid;font-size:10">Powered by <A HREF="http://www.freeaspupload.net/" style="color:black">Free ASP Upload</A></div>-->
<br><br>
</body>
</html>
