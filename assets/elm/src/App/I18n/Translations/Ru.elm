module App.I18n.Translations.Ru exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "Объект"

        Cotonoma ->
            "Профиль"

        MyHome ->
            "Домашняя"

        Post ->
            "Выслать"

        Posting ->
            "Передача"

        Save ->
            "Сохранить"

        Saving ->
            "Сохранение"

        Hide ->
            "Hide"

        Connection_LinkingPhraseInput ->
            "Linking phrase (optional)"

        Confirm ->
            "Подтвердить"

        ConfirmDeleteCoto ->
            "Вы уверены в необходимости удаления объекта?"

        ConfirmUnpinCoto ->
            "Вы уверены, что хотите открепить этот объект?"

        ConfirmDisconnect ->
            "Вы уверены в необходимости удаления этого соединения?"

        ConfirmCotonomatize name ->
            "Вы добавляете этот объект к профилю объекта " ++ name ++ "'"

        UnexpectedErrorOccurred ->
            "Возникла неожиданная ошибка."

        SigninModal_WelcomeTitle ->
            "Добро пожаловать в базу знаний ВотТак!"

        SigninModal_SignupEnabled ->
            "ВотТак не использует пароли. Просто введите свой электронный адрес, и мы вышлем вам ссылку на вход (или регистрацию)"

        SigninModal_OnlyForSignin ->
            "Просто введите свой адрес электронной почты, и мы вышлем вам ссылку на вход."

        SigninModal_SendLink ->
            "Отправить ссылку"

        SigninModal_Sending ->
            "Передача"

        SigninModal_EmailNotFound ->
            "Для этого электронного адреса вход воспрещен."

        SigninModal_SentTitle ->
            "Проверьте свой почтовый ящик!"

        SigninModal_SentMessage ->
            "Мы направили вам электронное письмо со ссылкой для доступа учетной записи ВотТак (или её создать)."

        Navigation_Current ->
            "Текущие"

        Navigation_Recent ->
            "Новые"

        Navigation_Watchlist ->
            "Watchlist"

        Flow_EditorPlaceholder ->
            "Опишите объект с помощью Markdown"

        Flow_ShortcutToOpenEditor ->
            "Нажми кнопку N"

        Flow_HideFlow ->
            "Скрыть профиль"

        Flow_OpenFlow ->
            "Развернуть профиль"

        Flow_Filter ->
            "Фильтр"

        Flow_StreamView ->
            "Текущий просмотр"

        Flow_TileView ->
            "Просмотр списка заголовков"

        Flow_Random ->
            "Random"

        Flow_NewPosts ->
            "new posts"

        Stock_DocumentView ->
            "Просмотреть как документ"

        Stock_GraphView ->
            "Просмотр строения базы"

        EditorModal_Summary ->
            "Заголовок(необязательно)"

        EditorModal_Content ->
            "Опишите объект с помощью Markdown"

        EditorModal_CotonomaName ->
            "Название темы"

        EditorModal_Preview ->
            "Просмотр"

        EditorModal_Edit ->
            "Изменить"

        EditorModal_CotonomaHelp ->
            "Профиль это тоже объект, имеющий сложное строение"
                ++ " здесь можно объединить усилия для исчерпывающего описания объекта."

        EditorModal_ShareCotonoma ->
            "Разрешить просмотр другим."

        EditorModal_ShareCotonomaNote ->
            "Только те, кто имеет ссылки на профиль или тему имеют к ним доступ"

        EditorModal_DuplicateCotonomaName ->
            "У Вас уже есть профиль объекта или тема с таким именем."

        EditorModal_TooLongForCotonomaName maxlength ->
            "Это имя должно быть длиной максимум "
                ++ toString maxlength
                ++ " символов, сейчас же: "

        ProfileModal_Title ->
            "О пользователе"

        ProfileModal_Name ->
            "Имя"

        ProfileModal_EmailAddress ->
            "Почтовый ящик"

        ProfileModal_Signout ->
            "Выйти"

        ProfileModal_Invite ->
            "Пригласить"

        ProfileModal_Export ->
            "Экспорт"

        ProfileModal_Import ->
            "Импорт"

        InviteModal_Title ->
            "Пригласить коллегу"

        InviteModal_Message ->
            "Введите почтовый адрес для отправки приглашения."

        InviteModal_SentMessage ->
            " Ваше приглашение было отправлено к: "

        InviteModal_InviteeAlreadyExists ->
            "Такой коллега уже есть: "

        InviteModal_SendInvite ->
            "Отправить приглашение"

        InviteModal_Sending ->
            "Посылаюф"

        InviteModal_InvitesRemaining invites ->
            if invites == 1 then
                toString invites ++ " invite remaining"

            else
                toString invites ++ " invites remaining"

        CotoToolbar_Connect ->
            "Присоединить к выбранным объектам"

        CotoToolbar_Pin ->
            "Прикрепить к текущему профилюф"

        CotoToolbar_Edit ->
            "Изменить"

        CotoToolbar_AddSubCoto ->
            "Добавить к присоединенному объекту"

        CotoToolbar_Select ->
            "Выбрать"

        CotoToolbar_More ->
            "Больше"

        CotoToolbar_EditConnection ->
            "Edit the connection"

        CotoToolbar_Reorder ->
            "Изменить порядок"

        CotoMenuModal_Info ->
            "Информация"

        CotoMenuModal_ExploreConnections ->
            "Просмотреть соединения"

        CotoMenuModal_PinToMyHome ->
            "Прикрепить к домашней странице"

        CotoMenuModal_UnpinFromMyHome ->
            "Убрать с домашней страници"

        CotoMenuModal_PinToCotonoma ->
            "Прикрепить к текущему профилю"

        CotoMenuModal_UnpinFromCotonoma ->
            "Открепите от существующего профиля объекта или темы"

        CotoMenuModal_Edit ->
            "Изменить"

        CotoMenuModal_AddSubCoto ->
            "Додати складову"

        CotoMenuModal_Cotonomatize ->
            "Преобразовать в тему"

        CotoMenuModal_Delete ->
            "Удалить"

        CotoMenuModal_Watch ->
            "Watch this Cotonoma"

        CotoMenuModal_Unwatch ->
            "Unwatch"

        TimelineFilterModal_Title ->
            "Фильтр по времени добавления"

        TimelineFilterModal_ExcludePinnedGraph ->
            "Скрыть объекты, включенные в прикреплены документы"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "Скрыть объекты не прикреплены к домашней странице"

        ConnectModal_Title ->
            "Підключити попередній перегляд"

        ConnectModal_Connect ->
            "Соединить"

        ConnectModal_PostAndConnect ->
            "Публиковать и соединить"

        ConnectModal_Reverse ->
            "Реверс"

        ConnectionModal_Title ->
            "Edit Connection"

        ConnectionModal_Disconnect ->
            "Отсоединить"

        CotoSelection_CotosSelected count ->
            if count == 1 then
                "объект выбран"

            else
                "объекты выбраны"

        Reorder_CloseReorderMode ->
            "Изменить порядок"
