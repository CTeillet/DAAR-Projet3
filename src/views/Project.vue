<template>
  <div class="home" v-if="companiesReady">
    <form @submit.prevent="createProject">
      <card
        title="Enter your project name here"
        subtitle="Type directly in the input and hit enter."
      >
        <input 
          type="text"
          class="input-project"
          v-model="projectName"
          placeholder="Type your project name here"
        />
        <br>
        <select v-model="projectType">
          <option disabled  value="">Select a project type</option>
          <option value="1">User owner</option>
          <option value="2">Company owner</option>
        </select>
        <br>
        If you selected user company, please choose a company
        <select v-model="companySelected" v-if="companies.length>0">
          <option 
            v-for="company in companies" :key="company.index" :value="company.index">
                  {{ company.name }}
          </option>
        </select>
        <br>
        <button type="submit"> Add project </button>
      </card>
    </form>
  </div>
  <div class="home" v-else>
    <card
      title="Loading"
      subtitle="Please wait while we load the companies"
    >
    </card>
  </div>
  <div class="home" v-if="projectsReady">
    <h1 v-if="projects.length==0">No projects</h1>
    <card
      v-for="project in projects" :key="project.index" :title="project.name" :subtitle="project.type">
      Name of the project: {{ project.name }}
      <br>
      <div v-if="project.ownerType==1">
        <h3>User owner</h3>
          <b>Name:</b> {{ project.ownerRes[0] }}
          <br>
      </div>
      <div v-else>
        <h3>Company owner</h3>
          <b>Name:</b> {{ project.companyOwnerRes[0] }}
          <br>
      </div>
      Balance of the project: {{ project.balance }}
      <form @submit.prevent="addTokenProject(money, project.index)">  
          <div class="card-body">
          Enter the amount you want to donate    
          <input
            type="number"
            class="input-money"
            v-model="money"
            placeholder="Type the amount of money you want to add"
          />
          </div>
      </form>
      <div >
      Give tokens to contributors
      <form @submit.prevent="giveTokenContributors(tokens, contributorsIndex, project.index)">
      <input
        type="number"
        class="input-money"
        v-model="tokens"
        placeholder="Type the amount of tokens you want to give">
      <select v-model="contributorsIndex">
        <option disabled  value="">Select a contributor</option>
        <option v-for="(contributor,index) in project.contributorsAdd" :key="index" :value="index">
          {{ contributor }}
        </option>
      </select>
      <button type="submit"> Give tokens </button>
      </form>
      </div>
      <form @submit.prevent="addCommit(link, project.index)">  
          <div class="card-body">
          Enter the the link of your commit    
          <input
            type="url"
            class="input-link"
            v-model="link"
            placeholder="Type the the link of your commit"
          />
          </div>
      </form>
      Contributors : 
      {{ project.contribAdd }}
      <br>
      <ol>
        <li v-for="contributor in project.contributorsAdd" :key="contributor"> 
          <strong>Name:</strong> {{ contributor[0] }}
          <br>
        </li>
      </ol>
      Bounties : 
      <ol>
        <li v-for="bounty in project.bountiesRes" :key="bounty"> 
          <strong>Name:</strong> {{ bounty.titleB }}
          <br>
          <strong>Description:</strong> {{ bounty.descriptionB }}
          <br>
          <strong>Amount:</strong> {{ bounty.amount }}
          <br>
          <strong>Status:</strong> {{ bounty.status }}
          <br>
        
          <form @submit.prevent="checkBounty(bounty.indexB, commitIndex)" v-if="bounty.status!=='Closed'">
            <select v-model="commitIndex"
              >
              <option disabled  value="">Select a Commit</option>
              <option v-for="commit in project.commitsRes" :key="commit.indexC" :value="commit.indexC">
                {{ commit.link }} - {{ commit.person }}
              </option>
              </select>
            <input type="submit" value="Valider Bounty"/>
            
          </form>
        </li>
      </ol>
      Commits :
      <ol>
        <li v-for="commit in project.commitsRes" :key="commit.indexC"> 
          <strong>Link:</strong> {{ commit.link }}
          <br>
          <strong>Person:</strong> {{ commit.person }}
          <br>
        </li>
      </ol>
    </card>
  </div>
  <div class="home" v-else>
    <card
      title="Loading"
      subtitle="Please wait while we load the projects"
    >
    </card>
  </div>
  <div class="home" v-if="projectsReady">
    <card 
      title='Create Bounty'
      subtitle="Create a bounty for your project"
      >

      <form @submit.prevent="createBounty">
        <input 
          type="text"
          class="input-bounty"
          v-model="bountyName"
          placeholder="Type your bounty name here"
        />
        <br>
        <input 
          type="text"
          class="input-bounty"
          v-model="bountyDescription"
          placeholder="Type your bounty description here"
        />
        <br>
        <input 
          type="text"
          class="input-bounty"
          v-model="bountyValue"
          placeholder="Type your bounty value here"
        />
        <br>
        Select your project : 
        <select v-model="projectSelected" v-if="projects.length>0">
          <option 
            v-for="project in projects" :key="project.index" :value="project.index">
                  {{ project.name }}
          </option>
        </select>
        <button type="submit"> Add bounty </button>
      </form>
    </card>
  </div>

</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
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
      companiesReady: false,
      projects: [],
      projectsReady: false,
      projectType: '',
      projectName: '',
      companySelected:0,
      projectSelected:0,
      bountyName: '',
      bountyDescription: '',
      bountyValue: '',
      money:0,
      link:'',
    }
  },
  methods: {
    async createProject() {
      const { contract, projectType, projectName, companySelected } = this
      let ownerType;
      let compO = companySelected;
      if (projectType === "1") {
        ownerType = true
        compO = 0
      }
      if(projectType === "2") {
        ownerType = false
      }
      await contract.methods.createProject(projectName, compO , ownerType).send()
      await this.viewProjects();
    },
    async viewCompanies() {
      const { contract } = this
      let companiesRes = await contract.methods.viewCompanies().call()
      let tempCompanies = await companiesRes.map(async (resProj:any) => {
        const company = resProj[0]
        const index = resProj[1]
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
      this.companiesReady = true
    },
    async viewProjects() {
      const { contract } = this
      let projectsRes = await contract.methods.viewProjects().call()
      let tempProjects = await projectsRes.map(async (resProj:any) => {
        const project = resProj[0]
        const index:number = resProj[1]
        const name:string = project[0]
        const ownerAdd = project[1]
        const ownerRes:string = await contract.methods.user(ownerAdd).call()
        const companyOwner:number = project[2]
        const ownerType:boolean = project[3]
        let companyOwnerRes = "";
        if(!ownerType){
          const companyOwnerComp = await contract.methods.getCompany(companyOwner).call()
          companyOwnerRes = companyOwnerComp[0]
        }
        const balance:number = project[4]
        const contribAdd = project[5]
        const contributorsAdd = []
        contributorsAdd.push(contribAdd)
        const contributors = []
        //for (let userAdd in contributorsAdd ){
          //const user = await contract.methods.user(userAdd).call()
          //contributors.push(user[0])
        //}
        let bounties = await contract.methods.getBounties(index).call()
        let tempBounties = await bounties.map(async (resBounty:any) => {
          const bounty = resBounty[0]
          const indexB:number = resBounty[1]
          const titleB:string = bounty[0]
          const descriptionB:string = bounty[1]
          const ownerAddB = bounty[2]
          const ownerResB = await contract.methods.user(ownerAddB).call()
          const ownerB:string = ownerResB[0]
          const amount:number = bounty[3]
          const statusTemp:boolean = bounty[4]
          let status = "";
          if(statusTemp){
            status = "Open"
          } else {
            status = "Closed"
          }
          return { titleB, descriptionB, ownerB, amount, status, indexB }
        })
        const bountiesRes = await Promise.all(tempBounties)
        let commits = await contract.methods.getCommits(index).call()
        let tempCommits = await commits.map(async (resCommit:any) => {
          const commit = resCommit[0]
          const indexC:number = resCommit[1]
          const link = commit[0]
          const person = commit[1]
          const personRes = await contract.methods.user(person).call()[0]
          const projectId:number = commit[3]
          return { link, personRes, projectId, indexC }
        })
        const commitsRes = await Promise.all(tempCommits)
        return { name, ownerRes, companyOwnerRes, ownerType, balance, contributorsAdd, bountiesRes, commitsRes, ownerAdd, index }
      })
      this.projects = await Promise.all(tempProjects)
      this.projectsReady = true
    },
    async createBounty() {
      const { contract, bountyName, bountyDescription, bountyValue, projectSelected } = this
      await contract.methods.createBounty(bountyName, bountyDescription , projectSelected, bountyValue).send()
      await this.viewProjects();
    },
    async addTokenProject(money:number, projectIndex:number) {
      const { contract } = this
      await contract.methods.addTokenProject(money, projectIndex).send()
      await this.viewProjects();
    },
    async addCommit(link:string, projectIndex:number) {
      const { contract } = this
      await contract.methods.addCommit(projectIndex, link).send()
      await this.viewProjects();
    },
    async checkBounty(bountyIndex:number, commitIndex:number) {
      const {contract } = this
      await contract.methods.checkBounty(bountyIndex, commitIndex).send();
      this.viewProjects();
    },
    async giveTokenContributors(money:number, contributorIndex:number, projectIndex:number) {
      const { contract } = this
      console.log(money, contributorIndex, projectIndex)
      await contract.methods.giveTokenContributors(money, projectIndex, contributorIndex).send()
      this.viewProjects();
    },
  },
  async mounted() {
    const { address, contract } = this
    await this.viewCompanies()
    await this.viewProjects()
    await contract.methods.user(address).call()
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
