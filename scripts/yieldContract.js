import hre from hardhat;
import ethers from hre.ethers;
import contractABI  from ('../artifacts/contracts/yieldFarm.sol/yieldFarm.json');
const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

async function main() {
    const signer = await ethers.getSigner("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199");
    const yieldContract = await ethers.getContractAt(
        contractABI.abi,
        contractAddress,
        signer
    );

    try {
        const addPool = await yieldContract.addPool(1000, 3, 100, 600);
        addPool.wait();
        console.log(addPool);

        const checkPoolDetails = await yieldContract.checkPoolDetails(1)
        console.log(checkPoolDetails.toString());

    } catch(error) {
        console.log(error);
    }
}

main();