const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('AucEngine', function () {
  let owner;
  let seller;
  let buyer;
  let auct;

  beforeEach(async function () {
    [owner, buyer] = await ethers.getSigners();

    const AucEngine = await ethers.getContractFactory('AucEngine', owner);
    auct = await AucEngine.deploy();
    await auct.deployed();
  });

  it('sets owner', async function () {
    const currentOwner = await auct.owner();
    expect(currentOwner).to.eq(owner.address);
  });
});
