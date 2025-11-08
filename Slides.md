**Apresentação do Projeto – Estrutura em Slides (Texto para a Lousa)

Slide 1 – Introdução do Projeto
Este aplicativo foi desenvolvido em Flutter com foco acadêmico, utilizando uma arquitetura profissional. Ele permite cadastrar usuários, criar clientes e gerenciar agendamentos. Os dados são armazenados localmente usando SQLite, garantindo que o funcionamento continue mesmo sem internet. O objetivo principal do projeto é demonstrar boas práticas, persistência local e separação de camadas.

Slide 2 – Arquitetura Geral
A estrutura é organizada em camadas:
Interface – telas que o usuário visualiza.
Controllers – fazem a lógica da tela e controlam o estado.
Repositórios – tratam e convertem os dados.
Datasources – executam comandos SQL no SQLite.
Banco Local – responsável pelo armazenamento definitivo.
Essa organização facilita manutenção e expansão do projeto.

Slide 3 – SQLite e Persistência Local
O app usa SQFlite para gerenciar o banco interno. Quando o app inicia, o banco e as tabelas são criados automaticamente. Todas as informações ficam gravadas no dispositivo, funcionando mesmo offline. Exemplo: dados de clientes e agendamentos.

Slide 4 – Datasources – Acesso ao Banco
Os datasources acessam diretamente o SQLite. Eles executam INSERT, SELECT, UPDATE e DELETE. Por exemplo, createCustomer insere um novo cliente no banco, enquanto getCustomers retorna todos os registros. O retorno é sempre em Map<String, dynamic>, e não em objeto de modelo.

Slide 5 – Por que Usar Datasource
Sem datasource, cada tela precisaria escrever comandos SQL. Com datasource, centralizamos tudo, facilitando manutenção. Se no futuro o app usar API externa, basta trocar o datasource sem mudar o restante do sistema.

Slide 6 – Repositórios – Camada de Regras
Os repositórios recebem os Map<String, dynamic> do datasource e convertem para objetos da aplicação, como CustomerModel. Também fazem o caminho inverso: transformam objeto em Map para salvar no banco. Os repositórios validam dados, tratam erros e garantem consistência.

Slide 7 – Repositórios Abstratos
Os repositórios começam como classes abstratas. Hoje usam SQLite. No futuro, podemos criar uma versão usando HTTP e uma API. As telas continuam funcionando porque o contrato permanece o mesmo.

Slide 8 – Models – Objetos do Sistema
Os modelos representam dados reais. Por exemplo: CustomerModel possui id, nome, telefone e observações. Cada modelo tem fromMap e toMap, facilitando conversão entre banco e classe do app.

Slide 9 – Gerência de Estado com ChangeNotifier
Os controllers estendem ChangeNotifier. Quando os dados mudam, o controller chama notifyListeners e a interface atualiza automaticamente. Assim, não é necessário usar setState em todas as telas, deixando o código mais limpo.

Slide 10 – Funcionamento do Controller
Exemplo prático: a tela solicita ao controller que traga todos os clientes. O controller chama o repositório. O repositório consulta o datasource, converte os resultados para modelos e devolve. O controller guarda os dados e notifica os widgets.

Slide 11 – Fluxo de Login
O usuário digita login e senha. O controller chama o repositório para validar no banco. Se estiver correto, o usuário é salvo em sessão e o app navega para a tela inicial. Esse fluxo simula autenticação real.

Slide 12 – Cadastro de Cliente
O usuário preenche o formulário. O controller envia os dados para o repositório. O repositório transforma o modelo em Map e salva no datasource. Ao concluir, a interface atualiza a lista automaticamente.

Slide 13 – Listagem de Clientes
O controller chama repository.getAll. O repositório busca no datasource. Os mapas retornados viram modelos. O controller guarda tudo e a tela exibe após notifyListeners.

Slide 14 – AppInitializer
Executa antes da interface abrir. Cria o banco, prepara tabelas e pode carregar dados do usuário logado anteriormente. Garante que tudo esteja pronto antes do app aparecer.

Slide 15 – AppInfo
Centraliza informações do app como nome, versão e constantes. Evita espalhar dados fixos pelo código, facilitando manutenção.

Slide 16 – Organização de Pastas
pages: telas que o usuário vê.
controllers: lógica e estado.
datasources: acesso SQL.
repositories: regras e conversão de dados.
models: representação dos dados.
services: serviços internos como banco.
widgets: componentes reutilizáveis.
Esse padrão deixa o projeto limpo e compreensível.

Slide 17 – Vantagens da Arquitetura
Fácil manutenção.
Separação clara de funções.
Possibilidade de trocar SQLite por API sem reescrever telas.
Código organizado e profissional.

Slide 18 – Conclusão
Projeto acadêmico com estrutura real, usando boas práticas de persistência local, camadas e gerenciamento de estado. Está pronto para ser expandido com novas funções e integração com backend remoto.
