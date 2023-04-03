$(document).ready(function () {
    fcn_valoresPadroes('');
    $('input[type="date"]').attr({ min: '1900-01-01', max: '2999-01-01' })
})

/* NOVA FUN��O PARA MOVER LISTAR*/
function fcn_moveList(p_list, p_listEnviar, p_seletorHDN, p_acao) {

    if (p_acao == 'down_all') $(p_listEnviar).append($(p_list).find('option'))
    else if (p_acao == 'down') $(p_listEnviar).append($(p_list).find('option:selected'))
    else if (p_acao == 'up_all') $(p_list).append($(p_listEnviar).find('option'))
    else if (p_acao == 'up') $(p_list).append($(p_listEnviar).find('option:selected'))

    //reoordena a listas
    $(p_listEnviar).html($(p_listEnviar).find('option').get().sort(function (a, b) { return a.text < b.text ? -1 : 1; }))
    $(p_list).html($(p_list).find('option').get().sort(function (a, b) { return a.text < b.text ? -1 : 1; }))

    $(p_seletorHDN).val($(p_listEnviar).find('option').map(function () { return $(this).val() }).get().join(','))
}


function fazPost(url, body) {
    console.log(body)
    let request = new XMLHttpRequest()
    request.open("POST", url, true)
    request.setRequestHeader("Content-type", "application/json")
    request.send(JSON.stringify(body))

    request.onload = function () {
        console.log(this.responseText)
    }
    return request.responseText
}

function fazPatch(url, body) {
    console.log(body)
    let request = new XMLHttpRequest()
    request.open("PATCH", url, true)
    request.setRequestHeader("Content-type", "application/json")
    request.send(JSON.stringify(body))

    request.onload = function () {
        console.log(this.responseText)
    }
    return request.responseText
}

function fazDelete(url) {
    let request = new XMLHttpRequest()
    request.open("DELETE", url, true)
    request.onload = function () {
        console.log(this.responseText)
    }
    return request.responseText
}


function fcn_bloquearCampos(seletor, bloquear_fl) {

    let camposDisabled = 'input[type=checkbox]:not(.notDisabled)' +
        ',input[type=radio]:not(.notDisabled)' +
        ',select:not(.notDisabled)' +
        ',button:not(.notDisabled)'

    let camposReadOnly = 'input[type=text]:not(.notDisabled)' +
        ',input[type=number]:not(.notDisabled)' +
        ',textarea:not(.notDisabled)' +
        ',input[type=date]:not(.notDisabled)' +
        ',input[type=time]:not(.notDisabled)'

    let classeHidden = '.disabledFunction'
    let classeBloqueio = 'disabledFunctionReset';

    if (bloquear_fl == '1') {
        $(seletor).find(camposDisabled).addClass(classeBloqueio).prop('disabled', 'disabled');
        $(seletor).find(camposReadOnly).addClass(classeBloqueio).prop('readOnly', 'readOnly');
        $(seletor).find(classeHidden).addClass(classeBloqueio).css('display', 'none');
    } else {
        $(seletor).find('.' + classeBloqueio).removeProp('disabled').removeProp('readOnly').removeClass(classeBloqueio);
        $(seletor).find(classeHidden + '.' + classeBloqueio).css('display', '').removeClass(classeBloqueio);
    }

}

function fcn_valoresPadroes(alvo, delay) {
    alvo += ' input'
    if (!delay) { delay = 0; }
    setTimeout(function () {

        $(alvo + '[type="text"].numero').off().on({
            keypress: function (event) { return fcn_validaTecla('[0]', event) }
            , paste: function (event) { return fcn_validaTecla('[0]', event) }
            , blur: function () { $(this).val($(this).val().replace(/\D/g, '')) }
        });
        $(alvo + '.nome').off().on({
            keypress: function (event) { return fcn_validaTecla('[a][A]{ ������������������������������������\'}', event) }
            , paste: function (event) { return fcn_validaTecla('[a][A]{ ������������������������������������\'}', event) }
        });

    }, delay);
}

function fcn_validaTecla(validacao, evento) {
    // onKeyPress="return fcn_validaTecla('[0]{,}', event);"
    var tecla = (window.event) ? event.keyCode : evento.which;
    var retorno = false;
    //alert('TECLA: ' + tecla + validacao.indexOf('[A]') + '\n' + validacao.indexOf('[a]') + '\n' + validacao.indexOf('[0]') + '\n' + validacao.indexOf('[!]') + '\n' + validacao.indexOf('{'));
    if (tecla == 8) {
        retorno = true;
    }
    if (validacao.indexOf('[A]') > -1) {//alert('Maiusculo');//A-Z
        if ((tecla > 64 && tecla < 91)) { retorno = true };
    }
    if (validacao.indexOf('[a]') > -1) {//a-z
        if ((tecla > 96 && tecla < 123)) { retorno = true };
    }
    if (validacao.indexOf('[0]') > -1) {//0-9
        if ((tecla > 47 && tecla < 58)) { retorno = true };
    }
    if (validacao.indexOf('[!]') > -1) {
        if ((tecla > 31 && tecla < 48)
            || (tecla > 57 && tecla < 64)
            || (tecla > 90 && tecla < 97)
            || (tecla > 122 && tecla < 127)) { retorno = true };
    }
    if (validacao.indexOf('{') > 0 && validacao.indexOf('}') > 0) {//{#,@,!,A,1,-}
        if (validacao.indexOf('{') < validacao.indexOf('}')) {
            var caracteres = validacao.substr(validacao.indexOf('{'), validacao.indexOf('}'));
            caracteres = caracteres.split("");
            for (index = 0; index < caracteres.length; ++index) {
                if (caracteres[index].charCodeAt(0) == tecla) retorno = true;
            }
        }
    }
    //alert(retorno);
    return retorno;
}

function fcn_limparCampos(seletor) {
    $(seletor).each(function (i) {
        $(this).find('input[type=checkbox]:checked,input[type=radio]:checked').not('.notClear').removeAttr('checked', false).prop('checked', false);
        $(this).find('input[type=text],input[type=hidden],input[type=number],input[type=date],input[type=time],select,textarea').not('.notClear').val('');
    });

}

function fcn_colocarValor(seletor, valor) {
    var elemento = $(seletor);
    var Tag = elemento.prop('tagName');
    var Tipo = elemento.prop('type');
    var Nome = elemento.prop('name');
    if (Tag == 'SELECT' || Tag == 'TEXTAREA' || (Tag == 'INPUT' && (Tipo == 'text' || Tipo == 'hidden' || Tipo == 'date' || Tipo == 'time'))) {
        elemento.val(valor);
        if (Tipo == 'text' && valor != '') { elemento.trigger('paste'); }
    }
    else if (Tag == 'INPUT' && (Tipo == 'checkbox' || Tipo == 'radio')) {
        elemento.removeProp('checked');
        if (valor.indexOf(',') > 0) {
            valor = valor.split(',');
            i = 0;
            while (valor[i]) { $('[name="' + Nome + '"][value="' + valor[i] + '"]').prop('checked', true); i++; }
        } else $('[name="' + Nome + '"][value="' + valor + '"]').prop('checked', true);
    } else if (Tag == 'LABEL' || Tag == 'SPAN' || Tag == 'P') {
        elemento.html(valor);
    }
}

function fcn_pegarValor(seletor) {
    var retorno = '';
    $(seletor).filter("input[type=text], input[type=password], input[type=hidden], input[type=date],input[type=number],input[type=time], select, textarea").each(function () {
        retorno = $(this).val().trim();
    });
    $(seletor).filter("input[type=radio]:checked").each(function () {
        retorno = $(this).val().trim();
    });
    $(seletor).filter("input[type=checkbox]:checked").each(function () {
        var valor = '';
        if (retorno != '' && retorno != undefined) { retorno += ',' + $(this).val().trim();; }
        else { retorno = $(this).val().trim(); }
    });
    return retorno;
}
function fcn_pegarValores(seletor) {
    var dados = new Object;
    $.each(
        $.unique(
            $(seletor)
                .find("input:not(.btn_notGetValue), select, textarea")
                .map(function () { return $(this).prop('name') })
                .get()
        ), function (index, nome) {
            var valor = fcn_pegarValor('[name="' + nome + '"]');
            if (valor != '') dados[nome] = fcn_pegarValor('[name="' + nome + '"]');
        }
    );
    return dados;
}
/* padrao ajax */
function fcn_getAJAX() {
    //verifica se o browser tem suporte a ajax, retorna um objeto do tipo AJAX
    try {
        vobj_ajax = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (e) {
        try {
            vobj_ajax = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (ex) {
            try {
                vobj_ajax = new XMLHttpRequest();
            } catch (exc) {
                //Quando o browser não suporta ajax, este bloco, exibe uma mensagem do tipo ALERT para o usuário, e seta o Objeto ajax para NULL
                fcn_alert('Atenção!', "Esse browser não possui recursos para a utilização de AJAX!");
                vobj_ajax = null;
            }
        }
    }
    return vobj_ajax;
}
/* padrao ajax */

//TRIM
function fcn_trim(pstr_string) {
    return pstr_string.replace(/^\s+|\s+$/g, "");
}

function fcn_validaDataMaxima(dataFormulario, addDays) {

    //Data digitada no formulário
    var diaDigitado, mesDigitado, anoDigitado;
    var diaFuturo, mesFuturo, anoFuturo;

    //Converte data para formato necessário
    split = dataFormulario.split('-');
    dataConvertida = split[0] + "-" + split[1] + "-" + split[2];

    diaDigitado = split[2];
    mesDigitado = split[1];
    anoDigitado = split[0];

    var depois = new Date();
    depois.setDate(depois.getDate() + addDays);

    if (depois.getDate() <= 9) {
        diaFuturo = "0" + depois.getDate();
    } else {
        diaFuturo = depois.getDate();
    }

    if ((depois.getMonth() + 1) <= 9) {
        mesFuturo = "0" + (depois.getMonth() + 1);
    } else {
        mesFuturo = (depois.getMonth() + 1);
    }

    if (depois.getFullYear() <= 9) {
        anoFuturo = "0" + depois.getFullYear();
    } else {
        anoFuturo = depois.getFullYear();
    }

    //Se dia digitado for maior que dia limite então barra
    if (parseInt(anoDigitado.toString() + mesDigitado.toString() + diaDigitado.toString()) > parseInt(anoFuturo.toString() + mesFuturo.toString() + diaFuturo.toString())) {
        return 1;
    } else {
        return 0;
    }

}

function fcn_validaDataMinima(dataFormulario, addDays) {

    //Data digitada no formulário
    var diaDigitado, mesDigitado, anoDigitado;
    var diaPassado, mesPassado, anoPassado;

    //Converte data para formato necessário
    split = dataFormulario.split('-');
    dataConvertida = split[0] + "-" + split[1] + "-" + split[2];

    diaDigitado = split[2];
    mesDigitado = split[1];
    anoDigitado = split[0];

    var antes = new Date();
    antes.setDate(antes.getDate() - addDays);

    if (antes.getDate() <= 9) {
        diaPassado = "0" + antes.getDate();
    } else {
        diaPassado = antes.getDate();
    }

    if ((antes.getMonth() + 1) <= 9) {
        mesPassado = "0" + (antes.getMonth() + 1);
    } else {
        mesPassado = (antes.getMonth() + 1);
    }

    if (antes.getFullYear() <= 9) {
        anoPassado = "0" + antes.getFullYear();
    } else {
        anoPassado = antes.getFullYear();
    }

    //Se dia digitado for maior que dia limite então barra
    if (parseInt(anoDigitado.toString() + mesDigitado.toString() + diaDigitado.toString()) < parseInt(anoPassado.toString() + mesPassado.toString() + diaPassado.toString())) {
        return 1;
    } else {
        return 0;
    }

}

function mascara_num(obj) {
    valida_num(obj)
    if (obj.value.match("-")) {
        mod = "-";
    } else {
        mod = "";
    }
    valor = obj.value.replace("-", "");
    valor = valor.replace(",", "");

    if (valor.length >= 3) {
        valor = poe_ponto_num(valor.substring(0, valor.length - 2)) + "," + valor.substring(valor.length - 2, valor.length);
    }
    obj.value = mod + valor;
}
function poe_ponto_num(valor) {
    valor = valor.replace(/\./g, "");
    if (valor.length > 3) {
        valores = "";
        while (valor.length > 3) {
            valores = "." + valor.substring(valor.length - 3, valor.length) + "" + valores;
            valor = valor.substring(0, valor.length - 3);
        }
        return valor + "" + valores;
    } else {
        return valor;
    }
}
function valida_num(obj) {
    numeros = new RegExp("[0-9]");
    while (!obj.value.charAt(obj.value.length - 1).match(numeros)) {
        if (obj.value.length == 1 && obj.value == "-") {
            return true;
        }
        if (obj.value.length >= 1) {
            obj.value = obj.value.substring(0, obj.value.length - 1)
        } else {
            return false;
        }
    }
}

function fcn_validaNumeroRG(event) {
    var vstr_caracter = document.layers ? event.which
        : document.all ? event.keyCode
            : event.keyCode;

    if (vstr_caracter != 46 && vstr_caracter != 8 && vstr_caracter != 9 && vstr_caracter != 88) {
        if ((vstr_caracter < 48 || vstr_caracter > 58) && (vstr_caracter < 96 || vstr_caracter > 105)) { return false; }
    }
}

function fcn_validaNumeroInteiro(event) {
    var vstr_caracter = document.layers ? event.which
        : document.all ? event.keyCode
            : event.keyCode;


    if (vstr_caracter != 46 && vstr_caracter != 8 && vstr_caracter != 9) {
        if ((vstr_caracter < 48 || vstr_caracter > 58) && (vstr_caracter < 96 || vstr_caracter > 105)) { return false; }
    }
}

/* ALERT */
function fcn_alert(title, text) {
    $.alert({
        title: title,
        content: text,
    });
}

function fcn_confirmSN(title, message) {
    var def = $.Deferred();

    $.confirm({
        title: title,
        content: message,
        buttons: {
            op1: {
                text: 'Sim',
                action: function () {
                    def.resolve();
                }
            },
            op2: {
                text: 'N&atilde;o',
                action: function () {
                    def.reject();
                }
            }
        }
    });
    return def.promise();
}

function fcn_confirmSNPesquisa(title, message) {
    var def = $.Deferred();

    $.confirm({
        title: title,
        content: message,
        buttons: {
            op1: {
                text: 'FINALIZAR',
                action: function () {
                    def.resolve();
                }
            },
            op2: {
                text: 'CONTINUAR',
                action: function () {
                    def.reject();
                }
            }
        }
    });
    return def.promise();
}

/* valida email */
function fcn_validacaoEmail(field) {
    usuario = field.value.substring(0, field.value.indexOf("@"));
    dominio = field.value.substring(field.value.indexOf("@") + 1, field.value.length);

    if (usuario == "" && dominio == "") {
        return false;
    }


    if (!((usuario.length >= 1) &&
        (dominio.length >= 3) &&
        (usuario.search("@") == -1) &&
        (dominio.search("@") == -1) &&
        (usuario.search(" ") == -1) &&
        (dominio.search(" ") == -1) &&
        (dominio.search(".") != -1) &&
        (dominio.indexOf(".") >= 1) &&
        (dominio.lastIndexOf(".") < dominio.length - 1))) {
        document.frm_newi.txt_email.value = ""
        fcn_alert('Atenção!', "E-mail inválido!");

    }

}

/* codifica string em methodos ajax por post */
function fcn_codifyString(stringCode) {

    let x = stringCode;
    let array = x.split("");
    let pstr_strigArray = ""

    for (i = 0; i < stringCode.length; i++) {
        if (pstr_strigArray.length > 0) {
            pstr_strigArray += "####" + array[i].charCodeAt(0);
        } else {
            pstr_strigArray += array[i].charCodeAt(0);
        }
    }
    return pstr_strigArray
}

function validacpfGympass() {

    s = document.frm_newi.txt_cpf;

    if (s.value == "") {
        return (false);
    }

    if (((s.value.length == 11) && (s.value == 11111111111) || (s.value == 22222222222) || (s.value == 33333333333) || (s.value == 44444444444) || (s.value == 55555555555) || (s.value == 66666666666) || (s.value == 77777777777) || (s.value == 88888888888) || (s.value == 99999999999) || (s.value == 00000000000))) {
        fcn_alert('Atenção!', "CPF inválido!");
        s.value = '';
        s.focus();
        return (false);
    }


    if (!((s.value.length == 11) || (s.value.length == 14))) {
        fcn_alert('Atenção!', "CPF inválido!");
        s.value = '';
        s.focus();
        return (false);
    }

    var checkOK = "0123456789";
    var checkStr = s.value;
    var allValid = true;
    var allNum = "";
    for (i = 0; i < checkStr.length; i++) {
        ch = checkStr.charAt(i);
        for (j = 0; j < checkOK.length; j++)
            if (ch == checkOK.charAt(j))
                break;
        if (j == checkOK.length) {
            allValid = false;
            break;
        }
        allNum += ch;
    }
    if (!allValid) {
        fcn_alert('Atenção!', "Favor preencher somente com dígitos o campo CPF!");
        s.value = '';
        s.focus();
        return (false);
    }

    var chkVal = allNum;
    var prsVal = parseFloat(allNum);
    if (chkVal != "" && !(prsVal > "0")) {
        fcn_alert('Atenção!', "CPF zerado !");
        s.value = '';
        s.focus();
        return (false);
    }

    if (s.value.length == 11) {
        var tot = 0;

        for (i = 2; i <= 10; i++)
            tot += i * parseInt(checkStr.charAt(10 - i));

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(9))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            s.focus();
            return (false);
        }

        tot = 0;

        for (i = 2; i <= 11; i++)
            tot += i * parseInt(checkStr.charAt(11 - i));

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(10))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            s.focus();
            return (false);
        }
    }
    else {
        var tot = 0;
        var peso = 2;

        for (i = 0; i <= 11; i++) {
            tot += peso * parseInt(checkStr.charAt(11 - i));
            peso++;
            if (peso == 10) {
                peso = 2;
            }
        }

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(12))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            s.focus();
            return (false);
        }

        tot = 0;
        peso = 2;

        for (i = 0; i <= 12; i++) {
            tot += peso * parseInt(checkStr.charAt(12 - i));
            peso++;
            if (peso == 10) {
                peso = 2;
            }
        }

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(13))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            s.focus();
            return (false);
        }
    }
    return (true);

}


function fcn_mascaraCelularDigitada(objeto) {
    if (objeto.value.length == 0)
        objeto.value = '(' + objeto.value;

    if (objeto.value.length == 3)
        objeto.value = objeto.value + ')';


    //são paulo com 9 digitos de celular
    if (Left(objeto.value, 4) == '(11)') {

        if (objeto.value.length == 9)
            objeto.value = objeto.value + '-';

    } else {

        if (objeto.value.length == 8)
            objeto.value = objeto.value + '-';
    }
}


function fcn_left(str, n) {
    if (n <= 0)
        return "";
    else if (n > String(str).length)
        return str;
    else
        return String(str).substring(0, n);
}

function fcn_horaMinuto(obj) {
    var c = document.layers ? event.which
        : document.all ? event.keyCode
            : event.keyCode;

    if (c == 0) {
        c = (document.all) ? event.keyCode : event.which;
    }

    if (c == 0) {
        evt = e || window.event;
        c = evt.keyCode;
    }

    //alert(c)

    if ((c < 48 || c > 58) && (c < 96 || c > 105) && (c < 37 || c > 40) && (c != 8) && (c != 46) && (c != 9)) { return false; }
    else {
        if ((obj.value.length == 2) && (c != 8) && (c != 46)) { obj.value = obj.value + ":" }
    }
}

//conta caracteres
var ns6 = document.getElementById && !document.all

function restrictinput(maxlength, e, placeholder) {
    if (window.event && event.srcElement.value.length >= maxlength)
        return false
    else if (e.target && e.target == eval(placeholder) && e.target.value.length >= maxlength) {
        var pressedkey = /[a-zA-Z0-9\.\,\/]/ //detect alphanumeric keys
        if (pressedkey.test(String.fromCharCode(e.which)))
            e.stopPropagation()
    }
}

function countlimit(maxlength, e, placeholder) {
    var theform = eval(placeholder)
    var lengthleft = maxlength - theform.value.length
    var placeholderobj = document.all ? document.all[placeholder] : document.getElementById(placeholder)
    if (window.event || e.target && e.target == eval(placeholder)) {
        if (lengthleft < 0)
            theform.value = theform.value.substring(0, maxlength)
        placeholderobj.innerHTML = lengthleft
    }
}

function displaylimit(thename, theid, thelimit) {
    var theform = theid != "" ? document.getElementById(theid) : thename
    var limit_text = 'max.: <b><span id="' + theform.toString() + '" class="text_blue">' + thelimit + '</span></b> caracteres'
    if (document.all || ns6)
        document.write(limit_text)
    if (document.all) {
        eval(theform).onkeypress = function () { return restrictinput(thelimit, event, theform) }
        eval(theform).onkeyup = function () { countlimit(thelimit, event, theform) }
    }
    else if (ns6) {
        document.body.addEventListener('keypress', function (event) { restrictinput(thelimit, event, theform) }, true);
        document.body.addEventListener('keyup', function (event) { countlimit(thelimit, event, theform) }, true);
    }
}

//libera flash
// When the page loads:
/*window.onload = function() {
    if (document.getElementsByTagName) {
        // Get all the tags of type object in the page.
        var objs = document.getElementsByTagName("object");

        for (i = 0; i < objs.length; i++) {
            // Get the HTML content of each object tag and replace it with itself.
            objs[i].outerHTML = objs[i].outerHTML;
        }
    }
}

// When the page unloads:
window.onunload = function() {
    if (document.getElementsByTagName) {
        //Get all the tags of type object in the page.
        var objs = document.getElementsByTagName("object");
        for (i = 0; i < objs.length; i++) {
            // Clear out the HTML content of each object tag to prevent an IE memory leak issue.
            objs[i].outerHTML = "";
        }
    }
}*/

// Máscara de telefone

// Máscara de telefone

function fcn_mascaraTelefoneDigitada(objeto) {
    if (objeto.value.length == 0)
        objeto.value = '(' + objeto.value;

    if (objeto.value.length == 3)
        objeto.value = objeto.value + ')';

    if (objeto.value.length == 8)
        objeto.value = objeto.value + '-';
}

function fcn_mascaraTelefone(objeto) {

    objeto.value = objeto.value.replace('-', '');
    objeto.value = objeto.value.replace('-', '');
    objeto.value = objeto.value.replace('-', '');


    if (objeto.value.length >= 8 && objeto.value.length < 12) {

        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('(', '');
        objeto.value = objeto.value.replace(')', '');

        for (i = 0; i < objeto.value.length; i++) {
            if (i == 0)
                objeto.value = '(' + objeto.value;

            if (i == 3)
                objeto.value = objeto.value.substring(0, 3) + ')' + objeto.value.substring(3, objeto.value.length)

            if (i == 8)
                objeto.value = objeto.value.substring(0, 8) + '-' + objeto.value.substring(8, objeto.value.length)
        }
    }

    //    if (objeto.value.length > 9 && objeto.value.length <= 10) {

    //        objeto.value = objeto.value.replace('-', '');
    //        objeto.value = objeto.value.replace('-', '');
    //        objeto.value = objeto.value.replace('-', '');

    //        for (i = 0; i < objeto.value.length; i++) {
    //            if (i == 0)
    //                objeto.value = '(' + objeto.value;

    //            if (i == 3)
    //                objeto.value = objeto.value.substring(0, 3) + ')' + objeto.value.substring(3, objeto.value.length)

    //            if (i == 8)
    //                objeto.value = objeto.value.substring(0, 8) + '-' + objeto.value.substring(8, objeto.value.length)
    //        }
    //    }

    if (objeto.value.length == 13) {

        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('-', '');
        objeto.value = objeto.value.replace('(', '');
        objeto.value = objeto.value.replace(')', '');

        for (i = 0; i < objeto.value.length; i++) {
            if (i == 0)
                objeto.value = '(' + objeto.value;

            if (i == 3)
                objeto.value = objeto.value.substring(0, 3) + ')' + objeto.value.substring(3, objeto.value.length)

            if (i == 9)
                objeto.value = objeto.value.substring(0, 9) + '-' + objeto.value.substring(9, objeto.value.length)
        }
    } else {
        if (objeto.value.length == 12) {

            objeto.value = objeto.value.replace('-', '');
            objeto.value = objeto.value.replace('-', '');
            objeto.value = objeto.value.replace('-', '');
            objeto.value = objeto.value.replace('(', '');
            objeto.value = objeto.value.replace(')', '');

            for (i = 0; i < objeto.value.length; i++) {
                if (i == 0)
                    objeto.value = '(' + objeto.value;

                if (i == 3)
                    objeto.value = objeto.value.substring(0, 3) + ')' + objeto.value.substring(3, objeto.value.length)

                if (i == 8)
                    objeto.value = objeto.value.substring(0, 8) + '-' + objeto.value.substring(8, objeto.value.length)
            }
        }
    }
}
//======================================================
// Fun��o para valida��o de telefone
//======================================================
function fcn_validaNumeroTelefone(pstr_telefone) {

    pstr_telefoneLimpo = pstr_telefone.replace(/\D/g, '')


    //var regex = new RegExp('^[1-9]{2}(([2-5]{1}[0-9]{7})|(9[0-9]{8}))$');
    //if (regex.test(pstr_telefoneLimpo)) {

    if (pstr_telefoneLimpo.indexOf("12345678") != -1) {
        return false;
    } else if (pstr_telefoneLimpo.indexOf("23456789") != -1) {

    } else if (pstr_telefoneLimpo.indexOf("3456789") != -1) {
        return false;
    } else if (pstr_telefoneLimpo.indexOf("456789") != -1) {
        return false;
    } else if (pstr_telefoneLimpo.indexOf("56789") != -1) {
        return false;
    }

    var i = 0;

    while (i <= 9) {

        var pstr_num = i.toString();

        if (pstr_telefoneLimpo.indexOf(pstr_num.repeat(8)) != -1) {
            return false;
        }

        i = i + 1;

    }

    return true;

    //} else {
    //return false;
    //}
}

//------------------------------------------------------
// Função para validação de CPF
//------------------------------------------------------
function validacpf(pint_idCampo) {
    var i;
    s = document.getElementById(pint_idCampo).value;

    if (s == '') { return false; }

    if (s.length < 11) {
        fcn_alert('Atenção!', "CPF Invalido!")
        document.getElementById(pint_idCampo).focus()
        return false;
    }

    var c = s.substr(0, 9);
    var dv = s.substr(9, 2);
    var d1 = 0;
    for (i = 0; i < 9; i++) {
        d1 += c.charAt(i) * (10 - i);
    }
    if (d1 == 0) {
        fcn_alert('Atenção!', "CPF Invalido!")
        document.getElementById(pint_idCampo).focus()
        return false;
    }
    d1 = 11 - (d1 % 11);
    if (d1 > 9) d1 = 0;
    if (dv.charAt(0) != d1) {
        fcn_alert('Atenção!', "CPF Invalido!")
        document.getElementById(pint_idCampo).focus()
        return false;
    }
    d1 *= 2;

    for (i = 0; i < 9; i++) {
        d1 += c.charAt(i) * (11 - i);
    }

    d1 = 11 - (d1 % 11);

    if (d1 > 9) d1 = 0;
    if (dv.charAt(1) != d1) {
        fcn_alert('Atenção!', "CPF Invalido!")
        document.getElementById(pint_idCampo).focus()
        return false;
    }
}

//------------------------------------------------------
// Função para validação de CPF / Cnpj
//------------------------------------------------------
//

function validacpfCnpj() {

    s = document.frm_newi.txt_cpf;

    if (s.value == "") {
        return (false);
    }

    if (((s.value.length == 11) && (s.value == 11111111111) || (s.value == 22222222222) || (s.value == 33333333333) || (s.value == 44444444444) || (s.value == 55555555555) || (s.value == 66666666666) || (s.value == 77777777777) || (s.value == 88888888888) || (s.value == 99999999999) || (s.value == 00000000000))) {
        fcn_alert('Atenção!', "CPF inválido!");
        document.frm_newi.txt_cpf.value = '';
        document.frm_newi.txt_cpf.focus();

        setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

        return (false);
    }


    if (!((s.value.length == 11) || (s.value.length == 14))) {
        fcn_alert('Atenção!', "CPF inválido!");
        s.value = '';
        document.frm_newi.txt_cpf.focus();

        setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

        return (false);
    }

    var checkOK = "0123456789";
    var checkStr = s.value;
    var allValid = true;
    var allNum = "";
    for (i = 0; i < checkStr.length; i++) {
        ch = checkStr.charAt(i);
        for (j = 0; j < checkOK.length; j++)
            if (ch == checkOK.charAt(j))
                break;
        if (j == checkOK.length) {
            allValid = false;
            break;
        }
        allNum += ch;
    }
    if (!allValid) {
        fcn_alert('Atenção!', "Favor preencher somente com dígitos o campo CPF!");
        s.value = '';
        document.frm_newi.txt_cpf.focus();

        setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

        return (false);
    }

    var chkVal = allNum;
    var prsVal = parseFloat(allNum);
    if (chkVal != "" && !(prsVal > "0")) {
        fcn_alert('Atenção!', "CPF zerado !");
        s.value = '';
        document.frm_newi.txt_cpf.focus();

        setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

        return (false);
    }

    if (s.value.length == 11) {
        var tot = 0;

        for (i = 2; i <= 10; i++)
            tot += i * parseInt(checkStr.charAt(10 - i));

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(9))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            document.frm_newi.txt_cpf.focus();

            setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

            return (false);
        }

        tot = 0;

        for (i = 2; i <= 11; i++)
            tot += i * parseInt(checkStr.charAt(11 - i));

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(10))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            document.frm_newi.txt_cpf.focus();

            setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

            return (false);
        }
    }
    else {
        var tot = 0;
        var peso = 2;

        for (i = 0; i <= 11; i++) {
            tot += peso * parseInt(checkStr.charAt(11 - i));
            peso++;
            if (peso == 10) {
                peso = 2;
            }
        }

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(12))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            document.frm_newi.txt_cpf.focus();

            setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

            return (false);
        }

        tot = 0;
        peso = 2;

        for (i = 0; i <= 12; i++) {
            tot += peso * parseInt(checkStr.charAt(12 - i));
            peso++;
            if (peso == 10) {
                peso = 2;
            }
        }

        if ((tot * 10 % 11 % 10) != parseInt(checkStr.charAt(13))) {
            fcn_alert('Atenção!', "CPF inválido!");
            s.value = '';
            document.frm_newi.txt_cpf.focus();

            setTimeout(function () { $('#txt_cpf').focus(); }, 10); //exceção para Firefox

            return (false);
        }
    }
    return (true);

}



//------------------------------------------------------
// Campo somente numerico
//------------------------------------------------------
function fcn_validaNumero(event) {
    var vstr_caracter = document.layers ? event.which
        : document.all ? event.keyCode
            : event.keyCode;


    if (vstr_caracter != 46 && vstr_caracter != 8 && vstr_caracter != 9) {
        if ((vstr_caracter < 48 || vstr_caracter > 58) && (vstr_caracter < 96 || vstr_caracter > 105)) { return false; }
    }
}


//------------------------------------------------------
// Para tabulação no campo
//------------------------------------------------------
function f_parar_tab(quem) { v_tab = false; }

//------------------------------------------------------
// Checa tabulação do campo
//------------------------------------------------------
function f_checar_tab() { v_tab = true; }

//------------------------------------------------------
// Formata data
//------------------------------------------------------
function f_data(obj, event) {

    if (obj.value.length == 9 || obj.value.length == 0 || obj.value.length == 10) {
        f_checar_tab()
    } else {
        v_tab = false;

        var c = document.layers ? event.which
            : document.all ? event.keyCode
                : event.keyCode;


        if (c == 0) {
            c = (document.all) ? event.keyCode : event.which;
        }

        if (c == 0) {
            evt = e || window.event;
            c = evt.keyCode;
        }

        if ((c < 48 || c > 58) && (c != 8)) { return false; }
        else {
            if ((obj.value.length == 2 || obj.value.length == 5) && (c != 8)) { obj.value = obj.value + "/" }
        }
    }
}

//------------------------------------------------------
// Consiste Data
//------------------------------------------------------
function f_consiste_data(obj) {

    if (obj.value.length > 0) {
        var v_data = obj.value
        var v_dia = v_data.substring(0, 2)
        var v_mes = v_data.substring(3, 5)
        var v_ano = v_data.substring(6, 10)

        if (v_dia < 0 || v_dia > 31 || v_dia.substring(0, 1) == "/" || v_dia.substring(1, 1) == "/") {
            fcn_alert('Atenção!', "Data com Dia inválido!");
            document.getElementById(obj.id).focus();
            document.getElementById(obj.id).select();
            return false;
        }

        if (v_mes < 0 || v_mes > 12 || v_mes.substring(0, 1) == "/" || v_mes.substring(1, 1) == "/") {
            fcn_alert('Atenção!', "Data com Mês inválido!");
            document.getElementById(obj.id).focus();
            document.getElementById(obj.id).select();
            return false;
        }

        if (v_ano < 1900 || v_ano > 2100 || v_ano.substring(0, 1) == "/" || v_ano.substring(1, 1) == "/" || v_ano.substring(2, 1) == "/" || v_ano.substring(3, 1) == "/") {
            fcn_alert('Atenção!', "Data com Ano inválido!");
            document.getElementById(obj.id).focus();
            document.getElementById(obj.id).select();
            return false;
        }
    }
}


//------------------------------------------------------
// verifica se algum radio foi selecionado
//------------------------------------------------------
function fcn_verificaCheckExcluir_checked(pObjCheckBox) {

    if (pObjCheckBox != undefined) {

        var vobj_checkBox = pObjCheckBox
        var vint_TT_checkBox = vobj_checkBox.length;
        var vstr_FL_selecionou = false;

        //verificando o total de check box
        if (isNaN(vint_TT_checkBox) == true) {
            vint_TT_checkBox = 1;
        }

        if (vint_TT_checkBox == 1) {

            if (vobj_checkBox.checked == true) {
                vstr_FL_selecionou = true;
            }

        } else {

            for (x = 0; x < vint_TT_checkBox; x++) {

                if (vobj_checkBox[x].checked == true) {
                    vstr_FL_selecionou = true;
                    break;
                }
            }
        }

        return vstr_FL_selecionou;

    } else {
        return false;
    }
}

//------------------------------------------------------
// muda a virgula
//------------------------------------------------------
function fcn_replaceCaracteres(pstr_campo) {

    var vstr_stringRetorno = document.getElementById(pstr_campo).value;

    vstr_stringRetorno = vstr_stringRetorno.replace(/"/g, "&quot;");
    vstr_stringRetorno = vstr_stringRetorno.replace(/'/g, "&quot;");
    vstr_stringRetorno = vstr_stringRetorno.replace(/,/g, "&comma;");

    return vstr_stringRetorno;
}

var getJSON = function (url, callback) {

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'json';
    xhr.onload = function () {
        var status = xhr.status;

        if (status == 200) {
            callback(null, xhr.response);
        } else {
            callback(status);
        }
    };
    xhr.send();
};

var getJSON2 = function (url, callback) {

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'json';
    xhr.onload = function () {
        var status = xhr.status
        if (status == 200) {
            callback(null, xhr.response);
        } else {
            callback(status);
        }
    };
    xhr.send();
};

//Compare values
function compareOptionValues(a, b) {

    // Radix 10: for numeric values
    // Radix 36: for alphanumeric values

    var sA = parseInt(a.value, 36);
    var sB = parseInt(b.value, 36);
    return 0
}

/////////////////////////////////////// COMBO LISTA DEFAULT PARAMETROS DINAMICO //////////////////////////////////

// Dual list move function
function fcn_moveDualListDefault(srcList, destList, moveAll, pstr_hdn, pbln_limpaHdn) {

    var selecionados = "";


    // Do nothing if nothing is selected
    if ((srcList.selectedIndex == -1) && (moveAll == false)) {
        return;
    }

    newDestList = new Array(destList.options.length);

    var len = 0;

    for (len = 0; len < destList.options.length; len++) {
        if (destList.options[len] != null) {
            newDestList[len] = new Option(destList.options[len].text, destList.options[len].value, destList.options[len].defaultSelected, destList.options[len].selected);
        }
    }

    for (var i = 0; i < srcList.options.length; i++) {
        if (srcList.options[i] != null && (srcList.options[i].selected == true || moveAll)) {
            // Statements to perform if option is selected
            // Incorporate into new list
            newDestList[len] = new Option(srcList.options[i].text, srcList.options[i].value, srcList.options[i].defaultSelected, srcList.options[i].selected);
            len++;
        }
    }

    // Sort out the new destination list
    newDestList.sort(compareOptionValues);   // BY VALUES
    //newDestList.sort( compareOptionText );   // BY TEXT

    // Populate the destination with the items from the new array
    for (var j = 0; j < newDestList.length; j++) {
        if (newDestList[j] != null) {
            destList.options[j] = newDestList[j];
        }
    }

    // Erase source list selected elements
    for (var i = srcList.options.length - 1; i >= 0; i--) {
        if (srcList.options[i] != null && (srcList.options[i].selected == true || moveAll)) {
            // Erase Source
            //srcList.options[i].value = "";
            //srcList.options[i].text  = "";
            srcList.options[i] = null;
        }
    }

    for (var i = 0; i < destList.options.length; i++) {
        selecionados = selecionados + '' + destList.options[i].value + ', ';
    }

    document.getElementById(pstr_hdn).value = selecionados.substring(0, selecionados.length - 2);

    if (pbln_limpaHdn == '1') {
        document.getElementById(pstr_hdn).value = '';
    }

}

//Monta lista
function fcn_listaDefault(lst_primary, lst_secundary, lst_envio, pstr_hdn) {


    var arrFbox = new Array();
    var arrTbox = new Array();
    var arrLookup = new Array();
    var i;

    for (i = 0; i < lst_secundary.options.length; i++) {
        arrLookup[lst_secundary.options[i].text] = lst_secundary.options[i].value;
        arrTbox[i] = lst_secundary.options[i].text;
    }

    var fLength = 0;
    var tLength = arrTbox.length;

    for (i = 0; i < lst_primary.options.length; i++) {
        arrLookup[lst_primary.options[i].text] = lst_primary.options[i].value;
        if (lst_primary.options[i].selected && lst_primary.options[i].value != "") {
            arrTbox[tLength] = lst_primary.options[i].text;
            tLength++;
        }
        else {
            arrFbox[fLength] = lst_primary.options[i].text;
            fLength++;
        }
    }

    arrFbox.sort();
    arrTbox.sort();
    lst_primary.length = 0;
    lst_secundary.length = 0;

    var c;

    for (c = 0; c < arrFbox.length; c++) {
        var no = new Option();
        no.value = arrLookup[arrFbox[c]];
        no.text = arrFbox[c];
        lst_primary[c] = no;
    }

    for (c = 0; c < arrTbox.length; c++) {
        var no = new Option();
        no.value = arrLookup[arrTbox[c]];
        no.text = arrTbox[c];
        lst_secundary[c] = no;
    }

    fcn_avancarDefault(lst_envio, pstr_hdn);
}

function fcn_avancarDefault(lst_envio, pstr_hdn) {

    var strValues = "";
    var boxLength = document.getElementById(lst_envio.id).length;
    var count = 0;

    if (boxLength != 0) {
        for (i = 0; i < boxLength; i++) {
            if (count == 0) {
                strValues = document.getElementById(lst_envio.id).options[i].value;
            }
            else {
                strValues = strValues + ", " + document.getElementById(lst_envio.id).options[i].value;
            }
            count++;
        }
    }


    //Carrega hidden selecionados com os valores selecionados
    document.getElementById(pstr_hdn).value = strValues
    //Valida Campos obrigatorios e da submit
}