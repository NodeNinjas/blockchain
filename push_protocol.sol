// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPUSHCommInterface {
    function sendNotification(address _channel, address _recipient, bytes calldata _identity) external;
}

contract PushNotifier {
    
    address constant EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    address public channelAddress = 0x99FfBf96C9b62aeCAa44729848b0753283C8666c;

    enum NotificationType { Broadcast, Targeted, Subset }

    function notify(
        address _receiver, 
        NotificationType notificationType, 
        string memory _title, 
        string memory _body
    ) 
        public 
    {
        string memory typeString;
        
        if (notificationType == NotificationType.Broadcast) {
            typeString = "1";
        } else if (notificationType == NotificationType.Targeted) {
            typeString = "3";
        } else if (notificationType == NotificationType.Subset) {
            typeString = "4";
        }

        IPUSHCommInterface(EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN).sendNotification(
            channelAddress,
            _receiver,
            bytes(
                string(
                    abi.encodePacked(
                        "0",
                        "+",
                        typeString,
                        "+",
                        _title,
                        "+",
                        _body
                    )
                )
            )
        );
    }
}
