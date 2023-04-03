<% 
    'Declara��o de vari�veis
    session.LCID                = 1046
    session.Timeout             = 1200
    server.ScriptTimeout        = 12000

    'Desenvolvimento
    ' "Data Source=KEVINFAISCA\\SQLEXPRESS; Initial Catalog=db_petshop;Integrated Security=True"
    ' "Driver={SQL Server};Server=KEVINFAISCA\\SQLEXPRESS;Database=db_petshop;Security=True"
    ' "petshopdsn"

    Public Const cstr_conexao   = "Driver={SQL Server};Server=KEVINFAISCA\\SQLEXPRESS;Database=db_petshop;Security=True"

    vstr_tituloSite             = "PetShop"
    vstr_statusSite             = "PetShop"
    vstr_emailSite              = "petshop@gmail.com.br"

    cstr_caminhoFisico          = request.ServerVariables("appl_physical_path") & "projetos\petshop"
    cstr_caminhoSite            = cstr_caminhoProtocolo & "://" & Request.ServerVariables("HTTP_HOST")
    cstr_caminhoSitePath        = cstr_caminhoSite & "/projetos/petshop"

'    cstr_caminhoFisico          = "C:\inetpub\wwwroot\projetos\petshop"
'    cstr_caminhoSitePath        = "C:\inetpub\wwwroot\projetos\petshop"
'    cstr_caminhoSite            = "C:\inetpub\wwwroot\projetos\petshop"

    'Habilita disparos de e-mail no site 1 - habilitado | 0 desabilitado'
    vstr_habilitaDisparoEmailSite = 0

    'Enumera��o das constantes que especifica com um comoro argumentos poderia ser interpretado.
    Public Const cint_adCmdStoredProc  = 4

    'Vari�vel objeto que referencia o objeto de comunica��o com o banco de dados'
    Public vobj_conexao

    vstr_caminho                = request.ServerVariables("URL")
    vint_posicao                = InstrRev(vstr_caminho, "/", len(vstr_caminho),0)
    vstr_nomePagina             = right(vstr_caminho,(len(vstr_caminho)-vint_posicao))

    if len(request.ServerVariables("QUERY_STRING")) > 0 then
        vstr_nomePaginaLog      = vstr_nomePagina & "?" & request.ServerVariables("QUERY_STRING")
    else
        vstr_nomePaginaLog      = vstr_nomePagina
    end if

    vstr_pasta                  = replace(replace(vstr_caminho,vstr_raiz,""),vstr_nomePagina,"")

    '--------------------------------------------------------------------------------------------------
    'Nome Fun��o    :   fcn_abrirConexao()'
    'Par�metros     :   nenhum
    'Retorno        :   Disponibilidade de conexao com a variavel vobj_conexao
    'Descricao      :   Abre a conexao com o banco de dados
    '--------------------------------------------------------------------------------------------------
    Public Function fcn_abrirConexao()
        set vobj_conexao = Server.CreateObject("ADODB.Connection")
        vobj_conexao.Open cstr_conexao
    end Function

    '--------------------------------------------------------------------------------------------------
    'Nome Fun��o    :   fcn_fechaConexao()'
    'Par�metros     :   nenhum
    'Retorno        :   Disponibilidade de conexao com a variavel vobj_conexao
    'Descricao      :   fecha a conexao do objeto vobj_conexao
    '--------------------------------------------------------------------------------------------------
    Public Sub fcn_fechaConexao()
        if isObject(vobj_conexao) then
            if vobj_conexao.State <> adStateClosed then
                vobj_conexao.Close
            end if

            Set vobj_conexao = Nothing
        end if
    end Sub

    '--------------------------------------------------------------------------------------------------
    'Nome Fun��o    :   fcn_limparString(pstr_string)'
    'Par�metros     :   pstr_string - qualquer string
    'Retorno        :   string sem aspas e caracteres proibidos
    'Descricao      :   fun��o limpa a string passada a ela
    '--------------------------------------------------------------------------------------------------
 '   Function fcn_limparString(pstr_string)
 '
 '       'Declara v�riavel para limpar string
 '        Dim vstr_string
 '
 '       'Tira espa�os em brancos
 '       vstr_string    = Trim(pstr_string)
 '       
 '       if len(vstr_string) > 0 then
 '           vstr_string = Replace(Replace(vstr_string,"'",""),"&",""),"""","")
 '       end if
 '
 '       if vstr_string  = "" OR vstr_string = " " then
 '           vstr_string = empty
 '       end if
 '
 '       'Retorno valor'
 '       fcn_limparString = vstr_string
 '   End Function

    '--------------------------------------------------------------------------------------------------
    'Nome Fun��o    :   fcn_primeiraMaiusc()
    'Par�metrosd    :   pstr_string
    'retorno        :   primeira letra maiscula
    'descri��o      :   transforma a primeira letra em maiscula
    '--------------------------------------------------------------------------------------------------
    function fcn_primeiraMaiusc(pstr_string)
        'declara��o da variavel
        dim vstr_retorno

        vstr_retorno = ucase(left(pstr_string,1)) & right(pstr_string,len(pstr_string)-1)
        'retorno'
        fcn_primeiraMaiusc = vstr_retorno
    end function

    '---------------------------------------------------------------------------------------------------
    'nome Fun��o    :   fcn_formataMoeda()
    'Par�metros     :   pstr_string
    'Retorno        :   formataMoeda
    'Descri��o      :
    '---------------------------------------------------------------------------------------------------
    function fcn_formataMoeda(pstr_string)
        'declara��o da variavel
        dim vstr_retorno

        if len(pstr_string) > 0 then
            if trim(cstr_caminho)   = trim("C:\Usu�rios\kmlfa\OneDrive\Documentos\5 semestre-KevinFaisca\desenvolvimentoDeSistemas\projetos\petShop") then
                vstr_retorno        = pstr_string
            else
                vstr_retorno        = replace(pstr_string, ".","")
                vstr_retorno        = replace(pstr_string,"R$","")
                vstr_retorno        = replace(pstr_string,"$","")
                vstr_retorno        = replace(pstr_string," ","")
            end if
        end if
        
        'retorno
        fcn_formataMoeda = vstr_retorno
    end function


%>