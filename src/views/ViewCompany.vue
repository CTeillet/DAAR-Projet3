<template>
  <div class="home" v-if="ready && (companies.length>0)">
      <card
        v-for="company in companies"
        :key="company.index"
        :title="company.name"
      >
        <div class="card-body"> Balance : {{ company.balance }} </div>
          <form @submit.prevent="addTokenCompany(money, company.index)">  
          <div class="card-body">      
          <input
            type="number"
            class="input-money"
            v-model="money"
            placeholder="Type the amount of money you want to add"
          />
          </div>
          </form>
        <div class="card-body"> Owner : {{ company.owner }} </div>
        <ul id="Users" >
          <li class="card-body"> Users :</li>
          <div v-if="company.users.length>0">
            <li v-for="(user, index) in company.users" 
            :key="index">
              {{ company.users[index] }}
            </li>
          </div>
          <li v-else> No users </li>
          <form @submit.prevent="addUserCompany(addressInput, company.index)">  
            <div class="card-body">      
              <input
                type="text"
                class="input-address"
                v-model="addressInput"
                placeholder="Type the address of the user you want to add"
              />
            </div>
          </form>
        </ul>
      </card>
    </div>
    <div class="home" v-else>
      <h1 >No companies</h1>
    </div>
</template>

<script lang="ts">
import { defineComponent, computed} from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)

    return { address, contract, balance }
  },
  data() {
    return {
      companies: [],
      ready: false,
    }
  },
  methods: {
    async viewCompanies() {
      const { contract } = this
      let companiesRes = await contract.methods.viewCompanies(this.address).call()
      let tempCompanies = await companiesRes.map(async (resComp:any) => {
        const company = resComp[0]
        const index = resComp[1]
        const name = company[0]
        const balance = company[1]
        const ownerAdd = company[2]
        const ownerRes = await contract.methods.user(ownerAdd).call()
        const owner = ownerRes[0]
        const usersAdd = company[3]
        const users = []
        for (let userAdd in usersAdd ){
          const user = await contract.methods.user(userAdd).call()
          users.push(user[0])
        }
        return { name, balance, owner, users, index }
      })
      this.companies = await Promise.all(tempCompanies)
      this.ready = true
    },
    async addTokenCompany(money:number, companyIndex:number) {
      const { contract } = this
      await contract.methods.addTokenCompany(money, companyIndex).send()
    },
    async addUserCompany(address:string, companyIndex:number) {
      const { contract } = this
      await contract.methods.addUserCompany(address, companyIndex).send()
    }
  },
  async mounted() {
    const { address, contract } = this
    await contract.methods.user(address).call()
    await this.viewCompanies()
  },
})
</script>

<style lang="css" scoped>
.home-wrapper {
  margin: auto 24px auto 24px;
}

.home {
  display: grid;
  align-items: center;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  grid-gap: 24px;
}

.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
</style>
