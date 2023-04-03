If EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME = 'sp_usuario')
BEGIN
	DROP PROCEDURE sp_usuario
END
GO

Create Procedure dbo.sp_usuario
	@vstr_tipoOper					char(3)			= null
	,@vint_numOper					int				= null
	,@id_usuario					int				= null
	,@ds_nome						varchar(200)	= null
	,@ds_email						varchar(200)	= null
	,@ds_login						varchar(200)	= null
	,@ds_senha						varchar(200)	= null
	,@nr_cpf						varchar(200)	= null
	,@ds_imagem						varchar(200)	= null
	,@id_perfil						varchar(200)	= null
	,@fl_status						bit				= null
	,@id_usuarioinclusao			varchar(200)	= null
	,@dt_inclusao					date			= null
	,@id_usuarioAlteracao			int				= null
	,@dt_alteracao					date			= null

AS

--Inicializa Transação
Begin Transaction

--Declara variavel para tratamento de erro
Declare @vstr_msgErro	as varchar(4000),
--Declara variavel para exec SQL
		@vstr_cmd		as Nvarchar(4000),
		@vstr_descLog	as varchar(500)

--Procedimento para Select
if @vstr_tipoOper = 'SEL'
begin
	
	if @vint_numOper = 1
	begin
		select 
			ds_nome
			,ds_login
			,ds_senha
			,ds_imagem
			,id_perfil
			,fl_status
		from
			tb_usuario
		where
			fl_status = 1
	end
	--login
	if @vint_numOper = 2
	begin
		select 
			ds_login
			,ds_senha
		from
			tb_usuario
		where
			ds_login = @ds_login and ds_senha = @ds_senha
	end
	
	
	
	
	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	Begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação SELECT'
		Goto Erro
	end
END

if @vstr_tipoOper = 'INS'
begin
	if @vint_numOper = 1
	begin
		if not exists (select 1 from tb_usuario where nr_cpf = @nr_cpf)
		begin
			DECLARE @TEMP_TB_id_usuario_ID table (id_usuario int)
			insert into tb_usuario(
				id_perfil
				,ds_nome
				,ds_email
				,nr_cpf
				,ds_login
				,ds_senha
				,id_usuarioInclusao
				,dt_inclusao		
			)OUTPUT inserted.id_usuario INTO @TEMP_TB_id_usuario_ID
			values(
				@id_perfil
				,@ds_nome
				,@ds_email
				,@nr_cpf
				,@ds_login
				,@ds_senha
				,@id_usuarioinclusao
				,getdate()
			)
			SELECT id_usuario from @TEMP_TB_id_usuario_ID
		end
		else
		begin
			select top 1 id_usuario from tb_usuario where nr_cpf = @nr_cpf
		end
	end

	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação de INSERT'
		goto Erro
	end
end

if @vstr_tipoOper = 'UPD'
begin
	--redefinir senha
	if @vint_numOper = 1
	begin
		update
			tb_usuario
		set
			ds_nome					= @ds_nome
			,nr_cpf					= @nr_cpf
			,ds_email				= @ds_email
		where
			id_usuario				= @id_usuario
	end
	
	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação de UPDATE'
		goto Erro
	end
end

-- ir para rotina de finalização de operação
	goto Fim

-- Rotina para tratamento de erro
	Erro:
		select @vstr_msgErro
		RollBack Transaction

-- Rotina para finalização da operação
	Fim:
	Commit Transaction