---
title:       "Vue parent-child component interaction"
description: "Vue interaction between parent and child components"
date:        2024-04-04
author:   "Devean"
tags:        ["Vue","Web front"]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/vue-parent-child-interaction.png"
keywords: ["Vue component interaction","Front web","Vue props","Vue router"]

---

## Parameter interaction

### Props interaction

+ Parent component 


<!-- ParentComponent.vue -->
```vue
<template>
  <ChildComponent :message="dynamicMessage" />
</template>

<script setup lang="ts">
import ChildComponent from './ChildComponent.vue';
import { ref } from 'vue';

const dynamicMessage = ref('Hello, world!');
// 在父组件中可以动态更新 dynamicMessage 的值
</script>
```

+ Child component

<!-- ChildComponent.vue -->
```vue
<template>
  <div>{{ message }}</div>
</template>
<script setup lang="ts">
import { defineProps } from 'vue';

const props = defineProps({
    message: String,
});

function showMessage() {
    console.log(props.message);
}

</script>
```





### Router interaction


+ Parent component
```vue
<!-- ParentComponent.vue -->

<template>
  <div>
    <h1>Parent Component</h1>
    <button @click="goToChild">Go to Child Component</button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const goToChild = () => {
  const parentId = '123'; // Example parent id
  router.push({ path: '/child', query: { id: parentId } });
}
</script>


```

+ Child component
```vue

<!-- ChildComponent.vue -->

<template>
  <div>
    <h1>Child Component</h1>
    <p>Parent Id: {{ parentId }}</p>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router';

const route = useRoute();
const parentId = route.query.id;
</script>
```