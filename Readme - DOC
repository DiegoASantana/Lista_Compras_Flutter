Documentação do Aplicativo "Lista de Compras"
Visão Geral
O Lista de Compras é um aplicativo desenvolvido para ajudar os usuários a criar, gerenciar e organizar suas listas de compras de forma prática e eficiente. Ele permite a criação de múltiplas listas, adição de itens, ajuste de quantidades e valores, além de reordenar itens conforme necessário.

1. Funcionalidades Principais
    • Criar novas listas de compras: O usuário pode criar várias listas com diferentes itens.
    • Adicionar e editar itens: Para cada item, o usuário pode adicionar nome, quantidade e valor unitário.
    • Reordenar itens: O usuário pode mover os itens para reorganizá-los conforme necessário.
    • Remover itens: Itens podem ser excluídos a qualquer momento.
    • Salvar e manter a ordem dos itens: Mesmo após fechar o aplicativo, a ordem personalizada dos itens é mantida.

2. Requisitos do Sistema
    • Android: Versão mínima: Android 6.0 (Marshmallow) ou superior.
    • iOS: (se aplicável) Versão mínima: iOS 11 ou superior.
    • Armazenamento: Aproximadamente 50 MB de espaço livre.
    • Permissões:
        ◦ Acesso ao armazenamento para salvar dados localmente.

3. Instruções de Uso
3.1. Tela Inicial
    • Ao abrir o aplicativo, o usuário verá uma lista de compras (se houver) ou a opção de criar uma nova lista.
3.2. Criando uma Nova Lista
    • Pressione o botão + no canto inferior direito para criar uma nova lista.
    • Dê um nome para a lista, escolha uma imagem (Opcional), e selecione uma cor para a lista. Pressione "Criar Lista".
    • A lista será criada e exibida na tela inicial.
3.3. Adicionando Itens à Lista
    • Toque na lista desejada para abri-la.
    • Pressione o botão + para adicionar um novo item.
    • Preencha o nome do item, quantidade e valor unitário. Pressione "Salvar".
    • O item será adicionado à lista com o valor total calculado automaticamente.
3.4. Editando e Reordenando Itens
    • Para editar um item, basta tocar no ícone de menu, do lado direito de cada item, selecionar ‘Editar’ e alterar os campos necessários.
    • Para reordenar, segure e arraste o item para a nova posição desejada.
    • A ordem será salva automaticamente.
3.5. Excluindo Itens
    • Para remover um item, basta tocar no ícone de menu, do lado direito de cada item, selecionar ‘Remover’.
    • Confirme a exclusão, e o item será removido da lista.

4. Funcionalidades Avançadas
4.1. Reordenação Persistente
    • Ao mover um item para cima ou para baixo na lista, a posição é salva no banco de dados, garantindo que, ao reabrir o aplicativo, a ordem dos itens continue conforme o usuário deixou.
4.2. Máscara de Moeda
    • Ao adicionar ou editar o valor de um item, o campo de valor unitário exibe uma máscara de moeda em tempo real, facilitando a inserção de valores corretos pelo usuário.

5. Banco de Dados
O aplicativo utiliza o SQLite como banco de dados local para armazenar as listas e itens.
Estrutura da Tabela "ShoppingList"
    • SPL_IdList: ID da Lista (chave primária)
    • SPL_NameList: Nome da Lista
    • SPL_QtyItems: Quantidade de itens incluso
    • SPL_IdColor: Definição de cor da lista
    • SPL_DateHours: Data e Hora da última atualização da Lista
    • SPL_Image: Imagem adicionada à lista

Estrutura da Tabela "Items"
    • ITM_IdItem: ID do item (chave primária)
    • ITM_IdList: ID da lista (chave estrangeira)
    • ITM_Item: Nome do item
    • ITM_Qty: Quantidade do item
    • ITM_Value: Valor unitário do item
    • ITM_TotalValue: Valor total (quantidade * valor unitário)
    • ITM_OrderItem: Posição do item na lista

6. Atualizações Futuras
    • Sincronização na nuvem: Possibilidade de salvar as listas na nuvem para acesso em múltiplos dispositivos.
    • Notificações de lembrete: Lembrar os usuários de itens que estão prestes a vencer ou que precisam ser comprados.

7. Suporte e Contato
Se você encontrar algum problema ou tiver dúvidas sobre o uso do aplicativo, entre em contato conosco:
    • Email: suporte@listadecompras.com
