<template>
  <div class="hello">
    <h1>The environment of the earth is deteriorating, please contribute to protecting the earth</h1>
    <el-row>
      <el-col :span="3">

      </el-col>
      <el-col :span="5">
        <h2>
          A total of {{all}} STC were raised
        </h2>

      </el-col>
      <el-col :span="2">

      </el-col>
      <el-col :span="4">
        <h2 v-if="account != ''">
          Account:{{account_less(account)}}
        </h2>
      </el-col>
      <el-col :span="4">

      </el-col>
      <el-col :span="4">
        <el-button type="success" round v-if="network_name(network_info) == 'Barnard' " size="large" @click="get_account">{{connect_state}}</el-button>
        <el-button type="success" round disabled v-else>Connect</el-button >
      </el-col>
    </el-row>

    <p></p>
    <el-row>
      <el-col :span="3">

      </el-col>
      <el-col :span="5">
        <h2>
          You can donate STC to help us
        </h2>
      </el-col>
      <el-col :span="4">


          <el-input-number v-model="num" :precision="4" :step="0.1" :max="100000000" />
      </el-col>
      <el-col :span="4">
          <el-slider v-model="num" :step="10" show-stops> </el-slider>


      </el-col>
      <el-col :span="4">
        <el-button @click="send">donate</el-button>
      </el-col>
    </el-row>




    <p></p>
    <img src="../../public/bg.png">
    <el-alert title="warning alert" type="warning" show-icon v-if="network_name(network_info) != 'Barnard'">
      Only On Barnard ,But Now {{network_name(network_info)}}
    </el-alert>






<!--    <ul v-infinite-scroll="load" class="infinite-list" style="overflow: auto">-->
<!--      <li v-for="i in count" :key="i" class="infinite-list-item">{{ i }}</li>-->
<!--    </ul>-->
  </div>

</template>

<script>
import { arrayify, hexlify } from '@ethersproject/bytes'
import BigNumber from 'bignumber.js'

import { providers, utils, bcs, encoding, version as starcoinVersion } from '@starcoin/starcoin'
export default {
  name: 'HelloWorld',
  props: {
    msg: String
  },
  data(){
    return {
      num : 1.00,
      count:0,
      network_info:'VOID',
      account:"",
      connect_state:'Connect',
      all:0,
      imgSrc:require('../../public/bg.png')
    }

  },
  methods:{
    load(){
      this.count += 2
    },
    async send_transaction_arg   (functionId,typearg,args) {
      let starcoinProvider =   new providers.Web3Provider(window.starcoin, 'any')
      const scriptFunction =await utils.tx.encodeScriptFunctionByResolve(functionId, typearg, args,'https://barnard-seed.starcoin.org')
      console.log(scriptFunction)
      // Multiple BcsSerializers should be used in different closures, otherwise, the latter will be contaminated by the former.
      const payloadInHex = (function () {
        const se = new bcs.BcsSerializer()
        scriptFunction.serialize(se)
        return hexlify(se.getBytes())
      })()
      console.log({ payloadInHex })

      const txParams = {
        data: payloadInHex,
      }
      txParams.expiredSecs = 120
      const transactionHash = await starcoinProvider.getSigner().sendUncheckedTransaction(txParams)
      return transactionHash
    },
    async get_account (  ){

      const newAccounts = await window.starcoin.request({
        method: 'stc_requestAccounts',
      })
      let account = newAccounts[0]
      this.connect_state = 'Connected'
      this.account = account;
      return account
    },
    async get_id   (  ){

      const chainInfo = await window.starcoin.request({
        method: 'chain.id',
      })
      let id = chainInfo

      return id
    },
    network_name (id){
      if(id != "Void")
        return  id.name[0].toUpperCase() + id.name.substr(1)
    },
    account_less(account){
      if(account != ""){
        console.log(account)
        let a = account.substr(0,6)
        let b = account.substr(30)
        return  a+"...."+b
      }

    }

    ,
    async send(){
      try {
        const functionId =  '0x040B76e04c4E6c523f8e096781ad7044::DonateToEnvironment_Script::Donation'
        const strTypeArgs = []
        const tyArgs = utils.tx.encodeStructTypeTags(strTypeArgs)

        const sendAmount = parseFloat(this.num)

        const BIG_NUMBER_NANO_STC_MULTIPLIER = new BigNumber('1000000000')
        const sendAmountSTC = new BigNumber(String(sendAmount), 10)
        const sendAmountNanoSTC = sendAmountSTC.times(BIG_NUMBER_NANO_STC_MULTIPLIER)
        const args = [
          BigInt(sendAmountNanoSTC.toString(10))
        ]
        let hash = this.send_transaction_arg(functionId, tyArgs, args);
        console.log(hash)
      } catch (error) {

        throw error
      }
    },
    async call (functionId,typearg,args)  {
      let starcoinProvider =   new providers.Web3Provider(window.starcoin, 'any')
      return new  Promise((resolver,reject)=>{ starcoinProvider.send(
          'contract.call_v2',
          [
            {
              function_id: functionId,
              type_args: typearg,
              args:args,
            },
          ],
      ).then((result) => {
        resolver(result)
      }).catch((err)=>{
        reject(err)
      })
      })

    }


  },
  async created() {
    //记录当前的网络信息
    let info = await this.get_id()
    this.network_info = info
    //注册钩子
    window.starcoin.on('chainChanged', async (id)=>{
      let info = await this.get_id()

      this.network_info = info
    })
    window.starcoin.on('accountsChanged', async (account)=>{
      this.account  = account[0]
    })
    let all = await this.call( "0x040B76e04c4E6c523f8e096781ad7044::DonateToEnvironment_Script::get_all",[],[]).catch(error=>{
      console.log(error)
    });

    const BIG_NUMBER_NANO_STC_MULTIPLIER = new BigNumber('1000000000')

    const sendAmountSTC = new BigNumber(String(all[0]), 10)
    this.all = sendAmountSTC.div(BIG_NUMBER_NANO_STC_MULTIPLIER).toString(10)
    console.log(all)

  },

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

.infinite-list {
  height: 300px;
  padding: 0;
  margin: 0;
  list-style: none;
}
.infinite-list .infinite-list-item {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 50px;
  background: var(--el-color-primary-light-9);
  margin: 10px;
  color: var(--el-color-primary);
}
.infinite-list .infinite-list-item + .list-item {
  margin-top: 10px;
}
.background{
  width:100%;
  height:100%;  /**宽高100%是为了图片铺满屏幕 */
  z-index:-1;
  position: absolute;
}
</style>
