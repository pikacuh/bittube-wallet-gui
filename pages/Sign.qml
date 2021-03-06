// Copyright (c) 2014-2018, The Monero Project
// Copyright (c) 2018, The BitTube Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import moneroComponents.Clipboard 1.0
import moneroComponents.WalletManager 1.0
import "../components" as MoneroComponents

Rectangle {
    id: mainLayout
    property bool messageMode: true
    property bool fileMode: false

    color: "transparent"

    Clipboard { id: clipboard }

    MessageDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: signatureVerificationMessage
        standardButtons: StandardButton.Ok
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    function displayVerificationResult(result) {
        if (result) {
            signatureVerificationMessage.title = qsTr("Good signature") + translationManager.emptyString
            signatureVerificationMessage.text  = qsTr("This is a good signature") + translationManager.emptyString
            signatureVerificationMessage.icon = StandardIcon.Information
        }
        else {
            signatureVerificationMessage.title = qsTr("Bad signature") + translationManager.emptyString
            signatureVerificationMessage.text  = qsTr("This signature did not verify") + translationManager.emptyString
            signatureVerificationMessage.icon = StandardIcon.Critical
        }
        signatureVerificationMessage.open()
    }

    // ================
    // Sign a message
    //   message:       [                   ] [SIGN]
    //   [SELECT] file: [                   ] [SIGN]
    //   signature:     [                   ]
    // ================
    // verify a message
    //   address:       [                   ]
    //   message:       [                   ] [VERIFY]
    //   [SELECT] file: [                   ] [VERIFY]
    //   signature:     [                   ]
    // ================

    // sign / verify
    ColumnLayout {
        anchors.top: parent.top
        anchors.margins: (isMobile)? 17 * scaleRatio : 20 * scaleRatio
        anchors.topMargin: 40 * scaleRatio
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: instructionsRect
            Layout.preferredHeight: (instructionsText.height + 26) * scaleRatio
            Layout.fillWidth: true
            radius: 2 * scaleRatio
            border.color: MoneroComponents.Style.defaultFontColor
            border.width: 1 * scaleRatio
            color: "transparent"

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: (instructionsText.height + 40) * scaleRatio

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: 22 * scaleRatio
                    Layout.preferredWidth: 22 * scaleRatio
                    Layout.leftMargin: 10 * scaleRatio
                    Layout.topMargin: 10 * scaleRatio
                    source: "../images/editIcon.png"
                }

                Text {
                    id: instructionsText
                    Layout.topMargin: 12 * scaleRatio
                    Layout.preferredWidth: (instructionsRect.width - 80) * scaleRatio
                    Layout.leftMargin: 6 * scaleRatio
                    text: qsTr("This page lets you sign/verify a message (or file contents) with your address.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15 * scaleRatio
                    textFormat: Text.RichText
                    color: MoneroComponents.Style.defaultFontColor
                }
            }
        }

        ColumnLayout {
            id: modeRow
            Layout.fillWidth: true

            Text {
                id: modeText
                Layout.fillWidth: true
                Layout.topMargin: 12 * scaleRatio
                Layout.preferredWidth: (instructionsRect.width - 80) * scaleRatio
                text: qsTr("Mode") + translationManager.emptyString
                wrapMode: Text.Wrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 20 * scaleRatio
                textFormat: Text.RichText
                color: MoneroComponents.Style.defaultFontColor
            }

            RowLayout {
                id: modeButtonsRow
                Layout.topMargin: 10 * scaleRatio

                MoneroComponents.StandardButton {
                    id: handleMessageButton
                    text: qsTr("Message") + translationManager.emptyString
                    enabled: fileMode
                    onClicked: {
                        messageMode = true;
                        fileMode = false;
                    }
                }

                MoneroComponents.StandardButton {
                    id: handleFileButton
                    text: qsTr("File") + translationManager.emptyString
                    enabled: messageMode
                    onClicked: {
                        fileMode = true;
                        messageMode = false;
                    }
                }
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: 1 * scaleRatio
            Layout.fillWidth: true
            Layout.topMargin: 8 * scaleRatio
            Layout.bottomMargin: 8 * scaleRatio
            color: MoneroComponents.Style.dividerColor
            opacity: MoneroComponents.Style.dividerOpacity
        }

        ColumnLayout {
            id: signSection
            spacing: 10 * scaleRatio

            MoneroComponents.Label {
                id: signTitleLabel
                fontSize: 20 * scaleRatio
                text: fileMode ? qsTr("Sign file") + translationManager.emptyString : qsTr("Sign message") + translationManager.emptyString
            }

            ColumnLayout{
                id: signMessageRow
                Layout.fillWidth: true
                spacing: 10 * scaleRatio
                visible: messageMode

                MoneroComponents.LineEditMulti{
                    id: signMessageLine
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter a message to sign") + translationManager.emptyString;
                    labelText: qsTr("Message") + translationManager.emptyString;
                    readOnly: false
                    onTextChanged: signSignatureLine.text = ''
                    wrapMode: Text.WrapAnywhere
                    pasteButton: true
                }
            }

            RowLayout {
                id: signFileRow
                Layout.fillWidth: true
                visible: fileMode

                MoneroComponents.LineEditMulti {
                    id: signFileLine
                    labelText: qsTr("File") + translationManager.emptyString
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    onTextChanged: signSignatureLine.text = ""
                    wrapMode: Text.WrapAnywhere
                    text: ''
                }

                MoneroComponents.StandardButton {
                    id: loadFileToSignButton
                    Layout.alignment: Qt.AlignBottom
                    small: false
                    text: qsTr("Browse") + translationManager.emptyString
                    enabled: true
                    onClicked: {
                      signFileDialog.open();
                    }
                }
            }

            ColumnLayout {
                id: signSignatureRow

                MoneroComponents.LineEditMulti {
                    id: signSignatureLine
                    labelText: qsTr("Signature") + translationManager.emptyString;
                    placeholderText: messageMode ? qsTr("Click [Sign Message] to generate signature") + translationManager.emptyString : qsTr("Click [Sign File] to generate signature") + translationManager.emptyString;
                    readOnly: true
                    Layout.fillWidth: true
                    copyButton: true
                    wrapMode: Text.WrapAnywhere
                }
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    id: clearSignButton
                    text: qsTr("Clear") + translationManager.emptyString
                    enabled: signMessageLine.text !== '' || signFileLine.text !== ''
                    small: true
                    onClicked: {
                        signMessageLine.text = '';
                        signSignatureLine.text = '';
                        signFileLine.text = '';
                    }
                }

                MoneroComponents.StandardButton {
                    id: signMessageButton
                    visible: messageMode
                    text: qsTr("Sign Message") + translationManager.emptyString
                    enabled: signMessageLine.text !== ''
                    small: true
                    onClicked: {
                      var signature = appWindow.currentWallet.signMessage(signMessageLine.text, false)
                      signSignatureLine.text = signature
                    }
                }

                MoneroComponents.StandardButton {
                    id: signFileButton
                    visible: fileMode
                    small: true
                    Layout.alignment: Qt.AlignBottom
                    text: qsTr("Sign File") + translationManager.emptyString
                    enabled: signFileLine.text !== ''
                    onClicked: {
                        var signature = appWindow.currentWallet.signMessage(signFileLine.text, true);
                        signSignatureLine.text = signature;
                    }
                }
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: 1 * scaleRatio
            Layout.fillWidth: true
            Layout.topMargin: 8 * scaleRatio
            Layout.bottomMargin: 8 * scaleRatio
            color: MoneroComponents.Style.dividerColor
            opacity: MoneroComponents.Style.dividerOpacity
        }

        ColumnLayout {
            id: verifySection
            spacing: 16 * scaleRatio

            MoneroComponents.Label {
                id: verifyTitleLabel
                fontSize: 20 * scaleRatio
                text: fileMode ? qsTr("Verify file") + translationManager.emptyString : qsTr("Verify message") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: verifyMessageLine
                visible: messageMode
                Layout.fillWidth: true
                labelText: qsTr("Message") + translationManager.emptyString;
                placeholderText: qsTr("Enter the message to verify") + translationManager.emptyString;
                readOnly: false
                wrapMode: Text.WrapAnywhere
                text: ''
                pasteButton: true
            }

            RowLayout {
                id: verifyFileRow
                Layout.fillWidth: true
                visible: fileMode

                MoneroComponents.LineEditMulti {
                    id: verifyFileLine
                    labelText: qsTr("File") + translationManager.emptyString;
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    text: ''
                }

                MoneroComponents.StandardButton {
                    id: loadFileToVerifyButton
                    Layout.alignment: Qt.AlignBottom
                    small: false
                    text: qsTr("Browse") + translationManager.emptyString;
                    enabled: true
                    onClicked: {
                      verifyFileDialog.open()
                    }
                }
            }

            MoneroComponents.LineEditMulti {
                id: verifyAddressLine
                Layout.fillWidth: true
                labelText: qsTr("Address") + translationManager.emptyString;
                addressValidation: true
                placeholderText: "bx.. / bs.." + translationManager.emptyString;
                wrapMode: Text.WrapAnywhere
                text: ''
                pasteButton: true
            }

            MoneroComponents.LineEditMulti {
                id: verifySignatureLine
                labelText: qsTr("Signature") + translationManager.emptyString;
                placeholderText: qsTr("Enter the signature to verify") + translationManager.emptyString;
                Layout.fillWidth: true
                pasteButton: true
                wrapMode: Text.WrapAnywhere
                text: ''
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.topMargin: 12 * scaleRatio
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    id: clearVerifyButton
                    text: qsTr("Clear") + translationManager.emptyString
                    enabled: verifyMessageLine.text !== '' || verifyFileLine.text !== '' || verifyAddressLine.text !== '' || verifySignatureLine.text  !== ''
                    small: true
                    onClicked: {
                        verifyMessageLine.text = '';
                        verifySignatureLine.text = '';
                        verifyAddressLine.text = '';
                        verifyFileLine.text = '';
                    }
                }

                MoneroComponents.StandardButton {
                    id: verifyFileButton
                    visible: fileMode
                    small: true
                    text: qsTr("Verify File") + translationManager.emptyString
                    enabled: verifyFileLine.text !== '' && verifyAddressLine.text !== '' && verifySignatureLine.text !== ''
                    onClicked: {
                      var verified = appWindow.currentWallet.verifySignedMessage(verifyFileLine.text, verifyAddressLine.text, verifySignatureLine.text, true)
                      displayVerificationResult(verified)
                    }
                }

                MoneroComponents.StandardButton {
                    id: verifyMessageButton
                    visible: messageMode
                    small: true
                    text: qsTr("Verify Message") + translationManager.emptyString
                    enabled: verifyMessageLine.text !== '' && verifyAddressLine.text !== '' && verifySignatureLine.text !== ''
                    onClicked: {
                      var verified = appWindow.currentWallet.verifySignedMessage(verifyMessageLine.text, verifyAddressLine.text, verifySignatureLine.text, false)
                      displayVerificationResult(verified)
                    }
                }
            }
        }

        FileDialog {
            id: signFileDialog
            title: qsTr("Please choose a file to sign") + translationManager.emptyString;
            folder: "file://"
            nameFilters: [ "*"]

            onAccepted: {
                signFileLine.text = walletManager.urlToLocalPath(signFileDialog.fileUrl)
            }
        }

        FileDialog {
            id: verifyFileDialog
            title: qsTr("Please choose a file to verify") + translationManager.emptyString;
            folder: "file://"
            nameFilters: [ "*"]

            onAccepted: {
                verifyFileLine.text = walletManager.urlToLocalPath(verifyFileDialog.fileUrl)
            }
        }
    }

    function onPageCompleted() {
        console.log("Sign/verify page loaded");
    }
}
