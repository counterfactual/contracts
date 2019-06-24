pragma solidity 0.5.9;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./LibChallengeRules.sol";
import "./MAppInstanceAdjudicatorCore.sol";


contract MixinRefute is
  MAppInstanceAdjudicatorCore,
  LibChallengeRules
{

  event Refuted(
    bytes32 appInstanceId,
    AppInstanceState refutation
  );

  function refute(
    AppInstanceState memory refutationAppInstanceState,
    bytes memory signature
  )
    public
  {
    bytes32 appInstanceId = appInstanceIdFromAppInstanceState(refutationAppInstanceState);

    require(
      !isAppInstanceFinalized(appInstanceId),
      "Refute: channel must be open"
    );

    require(
      moveAuthorized(refutationAppInstanceState, signature),
      "Refute: move must be authorized"
    );

    require(
      LibChallengeRules.validRefute(
        outcomes[appInstanceId].challengeAppInstanceState,
        refutationAppInstanceState,
        signature
      ),
      "Refute: must be a valid refute"
    );

    bytes memory outcome = CounterfactualApp(
      refutationAppInstanceState.appDefinition
    ).computeOutcome(refutationAppInstanceState.appAttributes);

    MaybeOutcome memory updatedOutcome = MaybeOutcome(
      0,
      outcome,
      refutationAppInstanceState
    );

    outcomes[appInstanceId] = updatedOutcome;

    emit Refuted(appInstanceId, refutationAppInstanceState);

  }

}
