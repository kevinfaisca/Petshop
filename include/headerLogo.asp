<style>
    .dropdown-menu{
        left: initial !important;
        width: auto;
    }
    labal{
        position: inherit !important;
        color:inherit !important ;
        font-size: inherit !important;
    }
    .ul_menuDropdownHeader{
        display:none;
    }
    input#chk_abreMenuDropdown:checked + ul.ul_menuDropdownHeader{
        display: block;
        position: absolute;
        background-color: #002f85;
        z-index: 1000;
        list-style: none;
        padding: 0;
        top: 100%;
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
        overflow: hidden;
        box-shadow: 0px 5px 10px 0px #606060
    }
    ul.ul_menuDropdownHeader li{
        color: white;
        padding:5px;
        transition: 0.3s;
    }

    ul.ul_menuDropdownHeader li:hover{
        background-color: white;
        color: initial;
    }
    ul.ul_menuDropdownHeader a{
        text-decoration: none;
        color:initial;
    }
    .span_opcoesMenu{
        font-size: 14px;
        color: initial;
    }
</style>

<div class="row no-gutters m-0" style="background-color: #002f85">
    <div class="menu_topo col-md-10 offset-md-1 col-12">
        <nav class="navbar navbar-expand-lg d-flex align-items-center justify-content-center" id="navbar_logo">
            <a href="<%=vstr_local%>index.asp" class="navbar-brand navbar-nav mr-auto">
                <img src="<%=vstr_local%>imagens/pngs/logo.png" id="img_logoHeader" style="height: 35px; width: auto;" alt="logo_petShop"/>
            </a>

            <div class="mt-2 mt-sm-0">
                <%
                    if len(session("id_usuarioPetShop")) > 0 then
                %>
                    <span style="color:white;">Olá</span> <span style="color: white; font-weight: 700;"><%=session("ds_apelidoPetShop")%></span>
                    &nbsp;
                    <label for ="chk_abreMenuDropdown" class="m-0">
                        <img src="<%=vstr_local%>arquivos/fotoUsuario/<%=session("ds_imagemPetShop")%>"  style="height: 45px; width: 45px; border-radius: 100%; object-fit: cover; cursor: pointer;"   alt="fotoUsuario" />
                    </label>
                <%
                    end if    
                %>

                <input type="checkbox" name="chk_abreMenuDropdown" id="chk_abreMenuDropdown" style="display:none;" value="" />

                <ul class="ul_menuDropdownHeader">
                    <%
                        if trim(session("id_grupoPerfilPetShop")) = "1" or trim(session("id_grupoPerfilPetShop")) = "2" then
                    %>
                            <li onclick="javascript: window.location.href = '<%=vstr_local%>gerenciadorConteudo/vis_gerenciadorConteudo.asp'" style="cursor:pointer;">
                                <span class="span_opcoesMenu">Gerenciador de Conteúdo</span>
                            </li>
                    <%
                        end if
                    %>

                    <li onclick="javascript: window.location.href = '<%=vstr_local%>vis_usuarioPerfil.asp'" style="cursor:pointer;">
                        <span class="span_opcoesMenu">Perfil</span>
                    </li>

                    <li onclick="javascript: window.location.href = '<%=vstr_local%>login.asp?param=logoff'" style="cursor:pointer;">
                        <span class="span_opcoesMenu">Sair</span>
                    </li>
                </ul>
            </div>
        </nav>
    </div>
</div>