<%
    if trim(vstr_nomePagina) <> "login.asp" then
%>
    <!--#include file="footer.asp"-->
<%
    end if
%>

<script type="text/javascript">
    //$(document).ready(function (){ 
    //    $('.multi-select').multiselect({
    //        buttonText: function (options) {
    //            var retStr = "";
    //            if (options.length === 0) {
    //                retStr = "Selecione";
    //            } else {
    //                retStr = options.length + " selecionados";
    //            }
    //            return retStr
    //        }
    //    });
    //});

    var clipboard = new ClipboardJS('.copy-text', {
        container: document.getElementById('myModalCartao')
    });

    clipboard.on('sucess', function (e) {
        console.info('Action', e.action);
        console.info('Text:', e.action);
        console.info('Trigger:', e.action);
        fcn_alert('Atenção!', 'Link copiado com sucesso!');
    });
</script>
