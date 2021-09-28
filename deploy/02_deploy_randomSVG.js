module.exports = async ({
  getNamedAccounts,
  deployments,
  getChainId
}) => {
  const { deploy, get, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  let linkTokenAddress, vrfCoordinatorAddress;

  if (chainId == 31337) {
    let linkToken = await get('LinkToken');
    linkTokenAddress = linkToken.address;
    let vrfCoordinatorMock = await get('VRFCoordinatorMock');
    vrfCoordinatorAddress = vrfCoordinatorMock.address;
  } else {
    
  }
}