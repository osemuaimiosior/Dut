import { expect } from "chai";
import hre from "hardhat";

describe("Contract", function(){
    let myContract;

    before(async function () {
        const MyContract = await hre.ethers.getContractFactory("yieldFarm");
        myContract = await MyContract.deploy();
    });

    it("Should give the right result", async function (){
        it("Should give the right result", async function (){
            const poolDetails = await myContract.checkPoolDetails(0);
            expect(poolDetails[0]).to.equal(1000);  // first value
            expect(poolDetails[1]).to.equal(3);     // second value
            expect(poolDetails[2]).to.equal(100);   // third value
            expect(poolDetails[3]).to.equal(600);   // fourth value
        });
         
    })
})