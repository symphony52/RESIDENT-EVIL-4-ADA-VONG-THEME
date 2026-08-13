import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 1920
    height: 1080

    // Имя пользователя по умолчанию из конфигурации или последнее залогиненное
    property string realUsername: userModel.lastUser ? userModel.lastUser : (config.defaultUser || "PLAYER")

    // Подключаем ваш новый шрифт Garamond Regular
    FontLoader {
        id: isleFont
        source: "fonts/Garamond - Garamond - Regular.ttf"
    }

    // 1. Полноэкранный задний фон (Ваш скриншот с Дилером)
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || "backgrounds/background.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // 2. Единый центральный контейнер для всех элементов UI
    Item {
        id: uiContainer
        width: 450 
        height: 600
        anchors.centerIn: parent 

        Column {
            anchors.fill: parent
            spacing: 25

            // Текст приветствия (Яркое игровое золото с мягкой тенью для читаемости)
            Text {
                id: welcomeText
                width: parent.width
                text: "Welcome back, <b>" + root.realUsername + "</b>,<br>would you like to play a harmless game?"
                font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22")
                color: "#FCD08A" 
                wrapMode: Text.Wrap; lineHeight: 1.2
                horizontalAlignment: Text.AlignHCenter 
                
                style: Text.Normal
                Label {
                    anchors.fill: parent
                    text: parent.text
                    font: parent.font
                    color: "#000000"
                    opacity: 0.8
                    anchors.topMargin: 2
                    anchors.leftMargin: 2
                    z: -1
                }
            }

            // Блок живых часов и текущей даты
            Column {
                id: clockBlock
                width: parent.width
                spacing: 2
                anchors.horizontalCenter: parent.horizontalCenter 
                
                Text {
                    id: clockTime
                    text: Qt.formatTime(new Date(), "hh:mm:ss")
                    font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") * 2.4
                    color: "#FCD08A"; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter 
                }
                Text {
                    id: clockDate
                    text: Qt.formatDate(new Date(), "dddd, MMMM d")
                    font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") * 0.8
                    color: "#D4A359"; opacity: 0.9 
                    anchors.horizontalCenter: parent.horizontalCenter 
                }
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: {
                        clockTime.text = Qt.formatTime(new Date(), "hh:mm:ss")
                        clockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                    }
                }
            }
            // Вертикальный блок формы авторизации
            Item {
                id: formBlock
                width: parent.width
                height: 320
                z: 10

                // Поле логина (Имя пользователя)
                TextField {
                    id: usernameField
                    anchors.top: formBlock.top; width: formBlock.width; height: 42; text: root.realUsername
                    placeholderText: "Username"; font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") - 4
                    color: usernameField.activeFocus ? "#FFF0D4" : "#FAD096" // Сделали текст намного виднее и насыщеннее
                    placeholderTextColor: Qt.rgba(250/255, 208/255, 150/255, 0.35)
                    leftPadding: 15
                    background: Rectangle {
                        color: usernameField.activeFocus ? Qt.rgba(18/255, 12/255, 10/255, 0.85) : Qt.rgba(20/255, 15/255, 10/255, 0.6)
                        border.color: usernameField.activeFocus ? "#C2913F" : "#4A3618"
                        border.width: usernameField.activeFocus ? 2 : 1; radius: 0
                    }
                }

                // Поле ввода пароля
                TextField {
                    id: passwordField
                    anchors.top: usernameField.bottom; anchors.topMargin: 15; width: formBlock.width; height: 42
                    placeholderText: "ENTER PASSWORD TO SIGN THE WAIVER..."; echoMode: TextInput.Password
                    font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") - 4
                    color: passwordField.activeFocus ? "#FFF0D4" : "#FAD096" // Сделали пароль и плейсхолдер чёткими и видными
                    placeholderTextColor: Qt.rgba(250/255, 208/255, 150/255, 0.35)
                    leftPadding: 15
                    background: Rectangle {
                        color: passwordField.activeFocus ? Qt.rgba(18/255, 12/255, 10/255, 0.85) : Qt.rgba(20/255, 15/255, 10/255, 0.6)
                        border.color: passwordField.activeFocus ? "#C2913F" : "#4A3618"
                        border.width: passwordField.activeFocus ? 2 : 1; radius: 0
                    }
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex)
                        }
                    }
                }

                // Кнопка-селектор для отображения выбранной сессии
                Rectangle {
                    id: sessionSelector
                    anchors.top: passwordField.bottom; anchors.topMargin: 15; width: formBlock.width; height: 42
                    color: sessionSelector.isOpen ? Qt.rgba(18/255, 12/255, 10/255, 0.85) : Qt.rgba(20/255, 15/255, 10/255, 0.6)
                    border.color: isOpen ? "#C2913F" : "#4A3618"; border.width: 1; radius: 0
                    property bool isOpen: false
                    
                    Text {
                        anchors.left: sessionSelector.left; anchors.leftMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                        text: sessionModel.data(sessionModel.index(sessionList.currentIndex, 0), Qt.DisplayRole) || "Select Session"
                        font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") - 6
                        color: sessionSelector.isOpen ? "#FFF0D4" : "#FAD096"
                    }
                    Text {
                        anchors.right: sessionSelector.right; anchors.rightMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                        text: sessionSelector.isOpen ? "▲" : "▼"; font.pixelSize: 10; color: sessionSelector.isOpen ? "#FFF0D4" : "#FAD096"
                    }
                    MouseArea { anchors.fill: parent; onClicked: sessionSelector.isOpen = !sessionSelector.isOpen }
                }

                // Кнопка входа EXECUTE
                Button {
                    id: loginButton
                    anchors.top: sessionSelector.bottom; anchors.topMargin: 15; width: formBlock.width; height: 42
                    text: "EXECUTE"; font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") - 4; font.bold: true
                    contentItem: Text {
                        text: loginButton.text; font: loginButton.font
                        color: loginButton.hovered ? "#120C0A" : "#D4A359"
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: loginButton.hovered ? Qt.rgba(214/255, 163/255, 89/255, 0.9) : Qt.rgba(18/255, 12/255, 10/255, 0.75)
                        border.color: "#D4A359"; border.width: 1; radius: 0; opacity: loginButton.pressed ? 0.8 : 1.0
                    }
                    onClicked: { sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex) }
                }
                // Кастомное выпадающее меню (Теперь прижато вплотную с anchors.topMargin: 0)
                Rectangle {
                    id: dropdownMenu
                    visible: sessionSelector.isOpen; anchors.top: sessionSelector.bottom; anchors.topMargin: 0
                    width: sessionSelector.width; height: Math.min(sessionModel.count * 40, 160)
                    color: Qt.rgba(18/255, 12/255, 10/255, 0.95); border.color: "#C2913F"; border.width: 1; radius: 0; z: 99
                    
                    ListView {
                        id: sessionList; anchors.fill: parent; model: sessionModel; currentIndex: sessionModel.lastIndex; clip: true
                        delegate: Rectangle {
                            width: dropdownMenu.width; height: 40
                            color: delegateMouse.containsMouse ? Qt.rgba(194/255, 145/255, 63/255, 0.2) : "transparent"
                            
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
                                text: model.name; color: delegateMouse.containsMouse ? "#FFF0D4" : "#FAD096"
                                font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "22") - 6
                            }
                            MouseArea {
                                id: delegateMouse; anchors.fill: parent; hoverEnabled: true
                                onClicked: { sessionList.currentIndex = index; sessionSelector.isOpen = false }
                            }
                        }
                    }
                }

                // Блок вывода текста ошибки в самом низу формы
                Text {
                    id: errorMessage
                    anchors.top: dropdownMenu.visible ? dropdownMenu.bottom : loginButton.bottom
                    anchors.topMargin: 14; anchors.horizontalCenter: formBlock.horizontalCenter
                    text: ""
                    font.family: isleFont.name; font.pixelSize: 15
                    color: "#A53A2B" 
                }
            }
        }
    }

    // Обработчик сигналов от демона SDDM при неверном пароле
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Incorrect waiver credentials. The Dealer wins."
            passwordField.text = ""
            passwordField.focus = true
        }
    }
}
