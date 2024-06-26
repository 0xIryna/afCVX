// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

IFurnace constant FURNACE = IFurnace(address(0xCe4dCc5028588377E279255c0335Effe2d7aB72a));

interface IFurnace {
    /// @dev Return the amount of clevCVX unrealised and realised of user.
    /// @param _account The address of user.
    /// @return unrealised The amount of clevCVX unrealised.
    /// @return realised The amount of clevCVX realised and can be claimed.
    function getUserInfo(address _account) external view returns (uint256 unrealised, uint256 realised);

    /// @dev Deposit clevCVX in this contract to change for CVX.
    /// @param _amount The amount of clevCVX to deposit.
    function deposit(uint256 _amount) external;

    /// @dev Deposit clevCVX in this contract to change for CVX for other user.
    /// @param _account The address of user you deposit for.
    /// @param _amount The amount of clevCVX to deposit.
    function depositFor(address _account, uint256 _amount) external;

    /// @dev Withdraw unrealised clevCVX of the caller from this contract.
    /// @param _recipient The address of user who will recieve the clevCVX.
    /// @param _amount The amount of clevCVX to withdraw.
    function withdraw(address _recipient, uint256 _amount) external;

    /// @dev Withdraw all unrealised clevCVX of the caller from this contract.
    /// @param _recipient The address of user who will recieve the clevCVX.
    function withdrawAll(address _recipient) external;

    /// @dev Claim all realised CVX of the caller from this contract.
    /// @param _recipient The address of user who will recieve the CVX.
    function claim(address _recipient) external;

    /// @dev Exit the contract, withdraw all unrealised clevCVX and realised CVX of the caller.
    /// @param _recipient The address of user who will recieve the clevCVX and CVX.
    function exit(address _recipient) external;

    /// @dev Distribute CVX from `origin` to pay clevCVX debt.
    /// @param _origin The address of the user who will provide CVX.
    /// @param _amount The amount of CVX will be provided.
    function distribute(address _origin, uint256 _amount) external;
}
