// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPUSHCommInterface {
    function sendNotification(address _channel, address _recipient, bytes calldata _identity) external;
}

contract PushNotifier {
    address constant EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    address public channelAddress = 0x99FfBf96C9b62aeCAa44729848b0753283C8666c;

    enum NotificationType { Broadcast, Targeted, SubTargeted }

   
    struct UserSettings {
        bool receiveMarketingNotifications; 
        uint8 loanHealthThreshold; // (0-100)
    }

    mapping(address => UserSettings) public userSettings;

    function notify(
        address _receiver,
        NotificationType _type,
        string memory _title,
        string memory _body
    ) public {
        require(_type == NotificationType.Broadcast || userSettings[_receiver].receiveMarketingNotifications, "User opted out of this notification type.");

        string memory typeStr;
        if (_type == NotificationType.Broadcast) {
            typeStr = "1";
        } else if (_type == NotificationType.Targeted) {
            typeStr = "3";
        } else if (_type == NotificationType.SubTargeted) {
            typeStr = "4";
        }

        IPUSHCommInterface(EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN).sendNotification(
            channelAddress,
            _receiver,
            bytes(
                string(
                    abi.encodePacked(
                        "0",   
                        "+",
                        typeStr,
                        "+",
                        _title,
                        "+",
                        _body
                    )
                )
            )
        );
    }

    function updateUserSettings(bool _receiveMarketingNotifications, uint8 _loanHealthThreshold) public {
        require(_loanHealthThreshold <= 100, "Invalid threshold value");

        userSettings[msg.sender].receiveMarketingNotifications = _receiveMarketingNotifications;
        userSettings[msg.sender].loanHealthThreshold = _loanHealthThreshold;
    }

    function getUserSettings(address _user) public view returns (bool, uint8) {
        return (userSettings[_user].receiveMarketingNotifications, userSettings[_user].loanHealthThreshold);
    }
}
