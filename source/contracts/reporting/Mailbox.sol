pragma solidity 0.4.18;

import 'libraries/DelegationTarget.sol';
import 'libraries/Ownable.sol';
import 'libraries/token/ERC20Basic.sol';
import 'libraries/Initializable.sol';
import 'reporting/IMailbox.sol';
import 'trading/ICash.sol';
import 'libraries/Extractable.sol';


contract Mailbox is DelegationTarget, Extractable, Ownable, Initializable, IMailbox {
    function initialize(address _owner) public onlyInGoodTimes beforeInitialized returns (bool) {
        endInitialization();
        owner = _owner;
        return true;
    }

    //As a delegation target we cannot override the fallback, so we provide a specific method to deposit ETH
    function depositEther() public payable onlyInGoodTimes returns (bool) {
        return true;
    }

    function withdrawEther() public onlyOwner returns (bool) {
        // Withdraw any Cash balance
        ICash _cash = ICash(controller.lookup("Cash"));
        uint256 _tokenBalance = _cash.balanceOf(this);
        if (_tokenBalance > 0) {
            _cash.withdrawEtherTo(owner, _tokenBalance);
        }
        // Withdraw any ETH balance
        if (this.balance > 0) {
            require(owner.call.value(this.balance)());
        }
        return true;
    }

    function withdrawTokens(ERC20Basic _token) public onlyOwner returns (bool) {
        uint256 _balance = _token.balanceOf(this);
        require(_token.transfer(owner, _balance));
        return true;
    }

    function getProtectedTokens() internal returns (address[] memory) {
        address[] memory _protectedTokens = new address[](2);
        // address(1) is the sentinel value for Ether extraction
        _protectedTokens[0] = address(1);
        _protectedTokens[1] = ICash(controller.lookup("Cash"));
        return _protectedTokens;
    }
}
