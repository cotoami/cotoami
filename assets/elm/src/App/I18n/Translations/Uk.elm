module App.I18n.Translations.Uk exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "Об'єкт"

        Cotonoma ->
            "Зріз"

        MyHome ->
            "Домівка"

        Post ->
            "Слати"

        Posting ->
            "Надсилання"

        Save ->
            "Зберегти"

        Saving ->
            "Збереження"

        Hide ->
            "Hide"

        Connection_LinkingPhraseInput ->
            "Linking phrase (optional)"

        Confirm ->
            "Підтвердити"

        ConfirmDeleteCoto ->
            "Ви впевнені в необхідності видалення об'єкту?"

        ConfirmUnpinCoto ->
            "Ви впевнені, що хочете відкріпити цей об'єкт?"

        ConfirmDisconnect ->
            "Ви впевнені в необхідності видалення цього з'єднання?"

        ConfirmCotonomatize name ->
            "Ви додаєте цей об'єкт до профілю об'єкту " ++ name ++ "'"

        UnexpectedErrorOccurred ->
            "Виникла несподівана помилка."

        SigninModal_WelcomeTitle ->
            "Вітаємо в базі знань ТребаТак!"

        SigninModal_SignupEnabled ->
            "ТребаТак не використовує паролі. Просто введіть свою електронну адресу, і ми надішлемо вам посилання на вхід (або реєстрацію)"

        SigninModal_OnlyForSignin ->
            "Просто введіть свою адресу електронної пошти, і ми надішлемо вам посилання на вхід."

        SigninModal_SendLink ->
            "Надіслати посилання"

        SigninModal_Sending ->
            "Надсилання"

        SigninModal_EmailNotFound ->
            "За цією Електронною адресою заборонено входити."

        SigninModal_SentTitle ->
            "Перевірте свою поштову скриньку!"

        SigninModal_SentMessage ->
            "Ми надіслали вам електронний лист з посиланням, щоб отримати доступ до облікового запису ТребаТак (або його створити)."

        Navigation_Current ->
            "Поточні"

        Navigation_Recent ->
            "Нові"

        Navigation_Watchlist ->
            "Watchlist"

        Flow_EditorPlaceholder ->
            "Опишіть об'єкт за допомогою Markdown"

        Flow_ShortcutToOpenEditor ->
            "Тисніть кнопку N"

        Flow_HideFlow ->
            "Приховати профіль"

        Flow_OpenFlow ->
            "Розгорнути профіль"

        Flow_Filter ->
            "Фільтр"

        Flow_StreamView ->
            "Поточний перегляд"

        Flow_TileView ->
            "Перегляд списку заголовків"

        Flow_Random ->
            "Random"

        Flow_NewPosts ->
            "new posts"

        Stock_DocumentView ->
            "Переглянути як документ"

        Stock_GraphView ->
            "Перегляд будови бази"

        EditorModal_Summary ->
            "Заголовок (необов'язково)"

        EditorModal_Content ->
            "Опишіть об'єкт за допомогою Markdown"

        EditorModal_CotonomaName ->
            "Назва теми"

        EditorModal_Preview ->
            "Перегляд"

        EditorModal_Edit ->
            "Редагувати"

        EditorModal_CotonomaHelp ->
            "Профіль це теж об'єкт, що має складну будову"
                ++ " тут можна об'єднати зусилля для вичерпного опису об'єкту."

        EditorModal_ShareCotonoma ->
            "Дозволити перегляд іншим."

        EditorModal_ShareCotonomaNote ->
            "Тільки ті хто має посилання до профілю/теми мають туди доступ"

        EditorModal_DuplicateCotonomaName ->
            "Ви вже маєте профіль об‘єкту чи тему з таким ім‘ям."

        EditorModal_TooLongForCotonomaName maxlength ->
            "Це ім‘я має бути довжиною максимум "
                ++ toString maxlength
                ++ " символів, зараз же: "

        ProfileModal_Title ->
            "Про користувача"

        ProfileModal_Name ->
            "Ім'я"

        ProfileModal_EmailAddress ->
            "Поштова скринька"

        ProfileModal_Signout ->
            "Вийти"

        ProfileModal_Invite ->
            "Запросити"

        ProfileModal_Export ->
            "Експорт"

        ProfileModal_Import ->
            "Імпорт"

        InviteModal_Title ->
            "Запросити колегу"

        InviteModal_Message ->
            "Введіть поштову адресу для надсилання запрошення."

        InviteModal_SentMessage ->
            " Ваше запрошення було надіслано до: "

        InviteModal_InviteeAlreadyExists ->
            "Такий колега вже є: "

        InviteModal_SendInvite ->
            "Надіслати запрошення"

        InviteModal_Sending ->
            "Надсилаю"

        InviteModal_InvitesRemaining invites ->
            if invites == 1 then
                toString invites ++ " invite remaining"

            else
                toString invites ++ " invites remaining"

        CotoToolbar_Connect ->
            "Приєднати до вибраних об'єктів"

        CotoToolbar_Pin ->
            "Прикріпити до поточного профілю"

        CotoToolbar_Edit ->
            "Редагувати"

        CotoToolbar_AddSubCoto ->
            "Додати до приєднаного об'єкту"

        CotoToolbar_Select ->
            "Вибрати"

        CotoToolbar_More ->
            "Більше"

        CotoToolbar_EditConnection ->
            "Edit the connection"

        CotoToolbar_Reorder ->
            "Змінити порядок"

        CotoMenuModal_Info ->
            "Про"

        CotoMenuModal_ExploreConnections ->
            "Переглянути поєднання"

        CotoMenuModal_PinToMyHome ->
            "Прикріпити до Домівки"

        CotoMenuModal_UnpinFromMyHome ->
            "Відкріпити від Домівки"

        CotoMenuModal_PinToCotonoma ->
            "Pin to the current Cotonoma"

        CotoMenuModal_UnpinFromCotonoma ->
            "Відкріпити від існуючого профілю об‘єкта чи теми"

        CotoMenuModal_Edit ->
            "Редагувати"

        CotoMenuModal_AddSubCoto ->
            "Додати складову"

        CotoMenuModal_Cotonomatize ->
            "Перетворити в тему"

        CotoMenuModal_Delete ->
            "Видалити"

        CotoMenuModal_Watch ->
            "Watch this Cotonoma"

        CotoMenuModal_Unwatch ->
            "Unwatch"

        TimelineFilterModal_Title ->
            "Фільтр за часом додавання"

        TimelineFilterModal_ExcludePinnedGraph ->
            "Сховати об'єкти, включені в прикріплені документи"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "Приховати об'єкти не прикріплені до домівки"

        ConnectModal_Title ->
            "Підключити попередній перегляд"

        ConnectModal_Connect ->
            "Поеднати"

        ConnectModal_PostAndConnect ->
            "Публікувати та поєднати"

        ConnectModal_Reverse ->
            "Обернути"

        ConnectionModal_Title ->
            "Edit Connection"

        ConnectionModal_Disconnect ->
            "Роз'єднати"

        CotoSelection_CotosSelected count ->
            if count == 1 then
                "об'єкт вибрано"

            else
                "об'єкти вибрані"

        Reorder_CloseReorderMode ->
            "Змінити порядок"
