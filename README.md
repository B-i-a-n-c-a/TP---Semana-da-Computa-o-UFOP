Guia de Configuração do Projeto - Semana da Computação DECSI
============================================================

Este repositório contém o sistema completo da Semana da Computação, dividido em:

*   **Backend:** API em Python (FastAPI).
    
*   **Frontend:** Aplicativo Mobile (Flutter).
    

1\. Configurando o Banco de Dados (PostgreSQL)
----------------------------------------------

O Flutter não acessa o banco diretamente; ele se comunica com a nossa API Python.

1.  Abra o **pgAdmin 4**.
    
2.  Crie um banco de dados chamado: db\_evento\_decsi.
    
3.  **Criação das Tabelas:**
    
    *   No pgAdmin, clique com o botão direito no banco criado e vá em **Query Tool**.
        
    *   Abra o arquivo backend/database/schema.sql que está neste repositório.
        
    *   Copie o código SQL, cole no Query Tool e clique em **Execute (F5)**.
        

2\. Configurando o Backend (Python)
-----------------------------------

Abra o terminal na pasta /backend:

1.  PowerShellpython -m venv venv
    
2.  PowerShell.\\venv\\Scripts\\activate
    
3.  PowerShellpip install fastapi uvicorn psycopg2-binary python-dotenv
    
4.  **Configurar Variáveis de Ambiente:**
    
    *   Copie o arquivo .env.example e renomeie para .env.
        
    *   Preencha as credenciais do seu banco de dados local.
        

3\. Configurando o Frontend (Flutter)
-------------------------------------


### Instalação Básica 

1.  Baixe o SDK do Flutter no [site oficial](https://docs.flutter.dev/get-started/install/windows).
    
2.  Extraia em C:\\src\\flutter e adicione o caminho C:\\src\\flutter\\bin ao seu **Path** nas Variáveis de Ambiente do Windows.
    
3.  **Extensões do VS Code:** Instale as extensões Flutter e Dart.
    

### Preparação do Projeto

Abra o terminal na pasta /frontend:

PowerShell

Plain    flutter pub get   `

4\. Executando o Projeto
------------------------------------


### Passo 1: Iniciar o Backend

No terminal do backend (com venv ativo):

**PowerShell**

`   python main.py   `

### Passo 2: Iniciar o Frontend (Dispositivo Físico ou Chrome)

**Recomendação:** Use um celular Android real via cabo USB ou o próprio Google Chrome para testar a interface.

1.  Conecte seu celular e ative a **Depuração USB** nas opções de desenvolvedor.
    
2.  PowerShell# Para rodar no celular/dispositivo conectadoflutter run -d device\_id # Ou para testar rápido no navegadorflutter run -d chrome_(Para ver o ID do seu dispositivo, use o comando flutter devices)_.
    

📁 Estrutura de Pastas Relevante
--------------------------------

*   /backend/database/init.sql: Contém todos os comandos CREATE TABLE do projeto.
    
*   /backend/main.py: Ponto de entrada da API.
    
*   /frontend/lib/: Código fonte das telas em Flutter.