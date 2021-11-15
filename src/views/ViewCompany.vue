<template>
  Hello World
  <div class="home">
    <card title="View Companies" subtitle="To never be lost">
      <button v-on:click="viewCompany">Add 1</button>
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
    const company = ''
    return { company }
  },
  methods: {
    async viewCompany() {
      const { contract } = this
      let companies = await contract.methods.viewCompany(this.address).send()
      console.log(companies)
    },
  },
  async mounted() {
    const { address, contract } = this
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
