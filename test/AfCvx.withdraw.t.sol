// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC4626Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";

import { CVX } from "src/interfaces/convex/Constants.sol";
import { BaseForkTest } from "test/utils/BaseForkTest.sol";

contract AfCvxWithdrawForkTest is BaseForkTest {
    function test_previewWithdraw() public {
        uint256 assets = 100e18;
        address user = _createAccountWithCvx(assets);
        uint256 shares = _deposit(user, assets);

        vm.prank(user);
        afCvx.approve(address(afCvx), shares);

        _distributeAndBorrow();

        // weekly withdraw limit is zero
        // previewWithdraw returns shares
        assertEq(afCvx.maxWithdraw(user), 0);
        assertApproxEqAbs(afCvx.previewWithdraw(assets), shares, 0.5e18);
        vm.prank(user);
        // withdraw reverts
        vm.expectRevert(abi.encodeWithSelector(ERC4626Upgradeable.ERC4626ExceededMaxWithdraw.selector, user, assets, 0));
        afCvx.withdraw(assets, user, user);

        _updateWeeklyWithdrawalLimit(1000); // 10%
        assertEq(afCvx.weeklyWithdrawalLimit(), 9.96e18);

        uint256 maxWithdraw = afCvx.maxWithdraw(user);
        uint256 preview = afCvx.previewWithdraw(maxWithdraw);
        vm.prank(user);
        uint256 actual = afCvx.withdraw(maxWithdraw, user, user);
        assertEq(preview, actual);
        assertEq(preview, 10e18);
    }

    function test_withdraw() public {
        uint256 assets = 100e18;
        address user = _createAccountWithCvx(assets);

        _deposit(user, assets);
        assertEq(CVX.balanceOf(user), 0);
        assertEq(afCvx.balanceOf(user), 100e18);

        _distributeAndBorrow();

        uint256 maxWithdraw = afCvx.maxWithdraw(user);
        assertEq(maxWithdraw, 0);

        vm.startPrank(owner);
        afCvx.setWeeklyWithdrawShare(200); // 2%;
        afCvx.harvest(0);
        vm.stopPrank();

        maxWithdraw = afCvx.maxWithdraw(user);
        assertEq(maxWithdraw, 1.992e18);

        vm.startPrank(user);
        afCvx.approve(address(afCvx), afCvx.previewWithdraw(maxWithdraw));
        afCvx.withdraw(maxWithdraw, user, user);

        assertEq(CVX.balanceOf(user), maxWithdraw);
        assertEq(afCvx.balanceOf(user), 98e18);
    }

    function test_previewRedeem() public {
        uint256 assets = 100e18;
        address user = _createAccountWithCvx(assets);
        uint256 shares = _deposit(user, assets);

        vm.prank(user);
        afCvx.approve(address(afCvx), shares);

        _deposit(900e18);
        _distributeAndBorrow();

        // weekly withdraw limit is zero
        // previewRedeem returns assets
        assertApproxEqAbs(afCvx.previewRedeem(shares), assets, 0.5e18);
        vm.prank(user);
        // redeem reverts
        vm.expectRevert(abi.encodeWithSelector(ERC4626Upgradeable.ERC4626ExceededMaxRedeem.selector, user, assets, 0));
        afCvx.redeem(assets, user, user);

        _updateWeeklyWithdrawalLimit(1000); // 10%
        assertEq(afCvx.weeklyWithdrawalLimit(), 99.6e18);

        uint256 maxRedeem = afCvx.maxRedeem(user);
        uint256 preview = afCvx.previewRedeem(maxRedeem);
        vm.prank(user);
        uint256 actual = afCvx.redeem(maxRedeem, user, user);
        assertEq(preview, actual);
        assertApproxEqAbs(preview, 99.6e18, 1);
    }

    function test_redeem() public {
        uint256 assets = 100e18;
        address user = _createAccountWithCvx(assets);

        _deposit(user, assets);
        assertEq(CVX.balanceOf(user), 0);
        assertEq(afCvx.balanceOf(user), 100e18);

        _distributeAndBorrow();

        uint256 maxRedeem = afCvx.maxRedeem(user);
        assertEq(maxRedeem, 0);

        vm.startPrank(owner);
        afCvx.setWeeklyWithdrawShare(200); // 2%;
        afCvx.harvest(0);
        vm.stopPrank();

        maxRedeem = afCvx.maxRedeem(user);
        assertApproxEqAbs(maxRedeem, 2e18, 1);

        vm.startPrank(user);
        afCvx.approve(address(afCvx), maxRedeem);
        afCvx.redeem(maxRedeem, user, user);

        assertApproxEqAbs(CVX.balanceOf(user), 1.992e18, 1);
        assertApproxEqAbs(afCvx.balanceOf(user), 98e18, 1);
    }
}
