<%
'  For examples, documentation, and your own free copy, go to:
'  http://www.freeaspupload.net
'  Note: You can copy and use this script for free and you can make changes
'  to the code, but you cannot remove the above comment.

Class FreeASPUpload
	Public UploadedFiles
	Public FormElements

	Private VarArrayBinRequest
	Private StreamRequest
	Private uploadedYet

	Private Sub Class_Initialize()
		Set UploadedFiles = Server.CreateObject("Scripting.Dictionary")
		Set FormElements = Server.CreateObject("Scripting.Dictionary")
		Set StreamRequest = Server.CreateObject("ADODB.Stream")
		StreamRequest.Type = 1 'adTypeBinary
		StreamRequest.Open
		uploadedYet = false
	End Sub
	
	Private Sub Class_Terminate()
		If IsObject(UploadedFiles) Then
			UploadedFiles.RemoveAll()
			Set UploadedFiles = Nothing
		End If
		If IsObject(FormElements) Then
			FormElements.RemoveAll()
			Set FormElements = Nothing
		End If
		StreamRequest.Close
		Set StreamRequest = Nothing
	End Sub

	Public Property Get Form(sIndex)
		Form = ""
		If FormElements.Exists(LCase(sIndex)) Then Form = FormElements.Item(LCase(sIndex))
	End Property

	Public Property Get Files()
		Files = UploadedFiles.Items
	End Property

	'Calls Upload to extract the data from the binary request and then saves the uploaded files
	Public Sub Save(path,vstr_tipoArquivo,vstr_local,vstr_campo)
		Dim streamFile, fileItem

		if Right(path, 1) <> "\" then path = path & "\"

		if not uploadedYet then Upload vstr_tipoArquivo,vstr_local,vstr_campo

		For Each fileItem In UploadedFiles.Items
				Set streamFile = Server.CreateObject("ADODB.Stream")
				streamFile.Type = 1
				streamFile.Open
				StreamRequest.Position=fileItem.Start
				StreamRequest.CopyTo streamFile, fileItem.Length
				streamFile.SaveToFile path & fileItem.FileName, 2
				streamFile.close
				Set streamFile = Nothing
				fileItem.Path = path & fileItem.FileName
		 Next
	End Sub

	Public Function SaveBinRequest(path) ' For debugging purposes
		StreamRequest.SaveToFile path & "\debugStream.bin", 2
	End Function

	Public Sub DumpData() 'only works if files are plain text
		Dim i, aKeys, f
		response.write "Form Items:<br>"
		aKeys = FormElements.Keys
		For i = 0 To FormElements.Count -1 ' Iterate the array
			response.write aKeys(i) & " = " & FormElements.Item(aKeys(i)) & "<BR>"
		Next
		response.write "Uploaded File:<br>"
		For Each f In UploadedFiles.Items
			
			response.write "Name: " & f.FileName & "<br>"
			response.write "Type: " & f.ContentType & "<br>"
			response.write "Start: " & f.Start & "<br>"
			response.write "Size: " & f.Length & "<br>"
			
		 Next
   	End Sub

    'Gera uma string aleatória com 'n' dígitos
	'Usado para criar um nome aleatório para o arquivo
	function fnGeraChave(n)
		dim s

		randomize
		s = ""
		while len(s) < n
			s = chr (int((57 - 48 + 1) * Rnd + 48)) + s
		wend
		fnGeraChave = s
	end function

	Private Sub Upload(vstr_tipoArquivo,vstr_local,vstr_campo)
		Dim nCurPos, nDataBoundPos, nLastSepPos
		Dim nPosFile, nPosBound
		Dim sFieldName, osPathSep, auxStr

		'RFC1867 Tokens
		Dim vDataSep
		Dim tNewLine, tDoubleQuotes, tTerm, tFilename, tName, tContentDisp, tContentType
		tNewLine = Byte2String(Chr(13))
		tDoubleQuotes = Byte2String(Chr(34))
		tTerm = Byte2String("--")
		tFilename = Byte2String("filename=""")
		tName = Byte2String("name=""")
		tContentDisp = Byte2String("Content-Disposition")
		tContentType = Byte2String("Content-Type:")

		uploadedYet = true

		on error resume next
		VarArrayBinRequest = Request.BinaryRead(Request.TotalBytes)
		if Err.Number <> 0 then 
			response.write "<br><br><B>System reported this error:</B><p>"
			response.write Err.Description & "<p>"
			response.write "The most likely cause for this error is the incorrect setup of AspMaxRequestEntityAllowed in IIS MetaBase. Please see instructions in the <A HREF='http://www.freeaspupload.net/freeaspupload/requirements.asp'>requirements page of freeaspupload.net</A>.<p>"
			Exit Sub
		end if
		on error goto 0 'reset error handling

		nCurPos = FindToken(tNewLine,1) 'Note: nCurPos is 1-based (and so is InstrB, MidB, etc)

		If nCurPos <= 1  Then Exit Sub
		 
		'vDataSep is a separator like -----------------------------21763138716045
		vDataSep = MidB(VarArrayBinRequest, 1, nCurPos-1)

		'Start of current separator
		nDataBoundPos = 1

		'Beginning of last line
		nLastSepPos = FindToken(vDataSep & tTerm, 1)

		Do Until nDataBoundPos = nLastSepPos
			
			nCurPos = SkipToken(tContentDisp, nDataBoundPos)
			nCurPos = SkipToken(tName, nCurPos)
			sFieldName = ExtractField(tDoubleQuotes, nCurPos)

			nPosFile = FindToken(tFilename, nCurPos)
			nPosBound = FindToken(vDataSep, nCurPos)
			
			If nPosFile <> 0 And  nPosFile < nPosBound Then
				Dim oUploadFile
				Set oUploadFile = New UploadedFile
				
				nCurPos = SkipToken(tFilename, nCurPos)
				auxStr = ExtractField(tDoubleQuotes, nCurPos)
                ' We are interested only in the name of the file, not the whole path
                ' Path separator is \ in windows, / in UNIX
                ' While IE seems to put the whole pathname in the stream, Mozilla seem to 
                ' only put the actual file name, so UNIX paths may be rare. But not impossible.
                osPathSep = "\"
                if InStr(auxStr, osPathSep) = 0 then osPathSep = "/"
				oUploadFile.FileName = Right(auxStr, Len(auxStr)-InStrRev(auxStr, osPathSep))
				
				If trim(Right(oUploadFile.FileName,4)) <> "jfif" and ( Ucase(Right(oUploadFile.FileName,4)) = Ucase(vstr_tipoArquivo) or Ucase(vstr_tipoArquivo) = "TODOS" ) Then
					
					Set FSO = Server.CreateObject("Scripting.FileSystemObject")
					
					oUploadFile.FileName = replace(oUploadFile.FileName, "/", "")
					oUploadFile.FileName = replace(oUploadFile.FileName, "\", "")
					oUploadFile.FileName = replace(oUploadFile.FileName, "|", "")
                    oUploadFile.FileName = replace(oUploadFile.FileName, "'", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã ", "a")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã¡", "a")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã£", "a")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã§", "c")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã¨", "e")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã©", "e")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ãª", "e")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã¬", "i")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã­", "i")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã±", "n")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã²", "o")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã³", "o")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ãµ", "o")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ã¹", "u")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "Ãº", "u")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, ",", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, ";", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "ª", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "(", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, ")", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "[", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "]", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "}", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "{", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, ":", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "¡", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "£", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "§", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "¨", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "©", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "ª", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "¬", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "­", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "±", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "º", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "¹", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "²", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "³", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "µ", "")
	                oUploadFile.FileName = Replace(oUploadFile.FileName, "+", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "*", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "&", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "^", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "%", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "$", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "#", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "@", "")
					oUploadFile.FileName = Replace(oUploadFile.FileName, "!", "")
				    
                    If vstr_local = "Arquivos_Importacao" Then
						If FSO.FileExists(uploadsDirVar & oUploadFile.FileName) Then
							FSO.DeleteFile(uploadsDirVar & oUploadFile.FileName)
						End If
					End If
    
                    if trim(vstr_local) <> trim("Arquivos_Importacao") or vstr_local = "arquivoCategoriaPdv" then
                        oUploadFile.FileName = fnGeraChave(20) & "_" & oUploadFile.FileName
                    else
                        oUploadFile.FileName = oUploadFile.FileName
                    end if  

					If FSO.FileExists(uploadsDirVar & oUploadFile.FileName) = False then
						
						if (Len(oUploadFile.FileName) > 0) then 'File field not left empty
				
							nCurPos = SkipToken(tContentType, nCurPos)
							
							auxStr = ExtractField(tNewLine, nCurPos)
							' NN on UNIX puts things like this in the streaa:
							'    ?? python py type=?? python application/x-python
							oUploadFile.ContentType = Right(auxStr, Len(auxStr)-InStrRev(auxStr, " "))
							nCurPos = FindToken(tNewLine, nCurPos) + 4 'skip empty line
							
							oUploadFile.Start = nCurPos-1
							oUploadFile.Length = FindToken(vDataSep, nCurPos) - 2 - nCurPos
							
							If oUploadFile.Length > 0 Then UploadedFiles.Add LCase(sFieldName), oUploadFile
						End If
						
					else
						response.Redirect "profile.asp?ds_local=" & vstr_local & "&pstr_nomeInput=" & vstr_nomeInput & "&campo=" & vstr_campo & "&pstr_erro=Favor renomear o arquivo pois já existe um arquivo com esse nome!"
					end if
				Else
					response.Redirect "profile.asp?ds_local=" & vstr_local & "&pstr_nomeInput=" & vstr_nomeInput &  "&campo=" & vstr_campo & "&pstr_erro=Arquivo inválido!"
				End If
				
				

				
			Else
				Dim nEndOfData
				nCurPos = FindToken(tNewLine, nCurPos) + 4 'skip empty line
				nEndOfData = FindToken(vDataSep, nCurPos) - 2
				If Not FormElements.Exists(LCase(sFieldName)) Then FormElements.Add LCase(sFieldName), String2Byte(MidB(VarArrayBinRequest, nCurPos, nEndOfData-nCurPos))
			End If

			'Advance to next separator
			nDataBoundPos = FindToken(vDataSep, nCurPos)
		Loop
		StreamRequest.Write(VarArrayBinRequest)
	End Sub

	Private Function SkipToken(sToken, nStart)
		SkipToken = InstrB(nStart, VarArrayBinRequest, sToken)
		If SkipToken = 0 then
			Response.write "Error in parsing uploaded binary request."
			Response.End
		end if
		SkipToken = SkipToken + LenB(sToken)
	End Function

	Private Function FindToken(sToken, nStart)
		FindToken = InstrB(nStart, VarArrayBinRequest, sToken)
	End Function

	Private Function ExtractField(sToken, nStart)
		Dim nEnd
		nEnd = InstrB(nStart, VarArrayBinRequest, sToken)
		If nEnd = 0 then
			Response.write "Error in parsing uploaded binary request."
			Response.End
		end if
		ExtractField = String2Byte(MidB(VarArrayBinRequest, nStart, nEnd-nStart))
	End Function

	'String to byte string conversion
	Private Function Byte2String(sString)
		Dim i
		For i = 1 to Len(sString)
		   Byte2String = Byte2String & ChrB(AscB(Mid(sString,i,1)))
		Next
	End Function

	'Byte string to string conversion
	Private Function String2Byte(bsString)
		Dim i
		String2Byte =""
		For i = 1 to LenB(bsString)
		   String2Byte = String2Byte & Chr(AscB(MidB(bsString,i,1))) 
		Next
	End Function
End Class

Class UploadedFile
	Public ContentType
	Public Start
	Public Length
	Public Path
	Private nameOfFile

    ' Need to remove characters that are valid in UNIX, but not in Windows
    Public Property Let FileName(fN)
        nameOfFile = fN
        nameOfFile = SubstNoReg(nameOfFile, "\", "_")
        nameOfFile = SubstNoReg(nameOfFile, "/", "_")
        nameOfFile = SubstNoReg(nameOfFile, ":", "_")
        nameOfFile = SubstNoReg(nameOfFile, "*", "_")
        nameOfFile = SubstNoReg(nameOfFile, "?", "_")
        nameOfFile = SubstNoReg(nameOfFile, """", "_")
        nameOfFile = SubstNoReg(nameOfFile, "<", "_")
        nameOfFile = SubstNoReg(nameOfFile, ">", "_")
        nameOfFile = SubstNoReg(nameOfFile, "|", "_")
    End Property

    Public Property Get FileName()
        FileName = nameOfFile
    End Property

    'Public Property Get FileN()ame
End Class


' Does not depend on RegEx, which is not available on older VBScript
' Is not recursive, which means it will not run out of stack space
Function SubstNoReg(initialStr, oldStr, newStr)
    Dim currentPos, oldStrPos, skip
    If IsNull(initialStr) Or Len(initialStr) = 0 Then
        SubstNoReg = ""
    ElseIf IsNull(oldStr) Or Len(oldStr) = 0 Then
        SubstNoReg = initialStr
    Else
        If IsNull(newStr) Then newStr = ""
        currentPos = 1
        oldStrPos = 0
        SubstNoReg = ""
        skip = Len(oldStr)
        Do While currentPos <= Len(initialStr)
            oldStrPos = InStr(currentPos, initialStr, oldStr)
            If oldStrPos = 0 Then
                SubstNoReg = SubstNoReg & Mid(initialStr, currentPos, Len(initialStr) - currentPos + 1)
                currentPos = Len(initialStr) + 1
            Else
                SubstNoReg = SubstNoReg & Mid(initialStr, currentPos, oldStrPos - currentPos) & newStr
                currentPos = oldStrPos + skip
            End If
        Loop
    End If
End Function
%>
