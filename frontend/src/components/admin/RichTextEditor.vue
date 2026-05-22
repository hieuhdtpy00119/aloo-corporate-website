<script setup>
import { onBeforeUnmount, ref, watch } from 'vue'
import { EditorContent, useEditor } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import Underline from '@tiptap/extension-underline'
import TextAlign from '@tiptap/extension-text-align'
import { Table, TableCell, TableHeader, TableRow } from '@tiptap/extension-table'
import { uploadService } from '../../services/cmsService'

const props = defineProps({
  modelValue: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue'])
const isUploading = ref(false)

const uploadAndInsertImage = async (file, position = null) => {
  isUploading.value = true
  try {
    const { data } = await uploadService.image(file)
    const chain = editor.value?.chain().focus()
    if (position !== null) {
      chain?.insertContentAt(position, { type: 'image', attrs: { src: data.url } }).run()
    } else {
      chain?.setImage({ src: data.url }).run()
    }
  } catch (error) {
    console.warn('Could not upload editor image', error)
  } finally {
    isUploading.value = false
  }
}

const editor = useEditor({
  content: props.modelValue,
  extensions: [
    StarterKit,
    Underline,
    TextAlign.configure({
      types: ['heading', 'paragraph'],
    }),
    Table.configure({
      resizable: true,
    }),
    TableRow,
    TableHeader,
    TableCell,
    Image.configure({
      allowBase64: true,
    }),
    Link.configure({
      openOnClick: false,
      autolink: true,
      defaultProtocol: 'https',
    }),
  ],
  editorProps: {
    attributes: {
      class:
        'min-h-[400px] max-w-none px-5 py-4 text-slate-800 outline-none prose prose-slate prose-headings:text-avocado-950 prose-a:text-avocado-700 prose-img:rounded-xl prose-img:shadow-sm',
    },
    handleDrop(view, event) {
      const files = Array.from(event.dataTransfer?.files || []).filter((file) =>
        file.type.startsWith('image/'),
      )

      if (!files.length) return false
      event.preventDefault()

      files.forEach((file) => {
        const coordinates = view.posAtCoords({ left: event.clientX, top: event.clientY })
        const position = coordinates?.pos ?? view.state.selection.to
        uploadAndInsertImage(file, position)
      })

      return true
    },
  },
  onUpdate: ({ editor }) => {
    emit('update:modelValue', editor.getHTML())
  },
})

watch(
  () => props.modelValue,
  (value) => {
    if (editor.value && value !== editor.value.getHTML()) {
      editor.value.commands.setContent(value || '', false)
    }
  },
)

const setLink = () => {
  const previousUrl = editor.value?.getAttributes('link').href || ''
  const url = window.prompt('Nhập URL liên kết', previousUrl)

  if (url === null) return

  if (url === '') {
    editor.value?.chain().focus().extendMarkRange('link').unsetLink().run()
    return
  }

  editor.value?.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
}

const insertTable = () => {
  editor.value?.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run()
}

const addImageByUrl = () => {
  const url = window.prompt('Nhập URL ảnh')
  if (url) {
    editor.value?.chain().focus().setImage({ src: url }).run()
  }
}

const uploadImage = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  await uploadAndInsertImage(file)
  event.target.value = ''
}

onBeforeUnmount(() => {
  editor.value?.destroy()
})
</script>

<template>
  <div class="overflow-hidden rounded-xl border border-slate-200 bg-white">
    <div v-if="editor" class="sticky top-0 z-10 flex flex-wrap gap-2 border-b border-slate-200 bg-slate-50/95 p-3 backdrop-blur">
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('bold') }" @click="editor.chain().focus().toggleBold().run()">B</button>
      <button type="button" class="toolbar-btn italic" :class="{ active: editor.isActive('italic') }" @click="editor.chain().focus().toggleItalic().run()">I</button>
      <button type="button" class="toolbar-btn underline" :class="{ active: editor.isActive('underline') }" @click="editor.chain().focus().toggleUnderline().run()">U</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('heading', { level: 2 }) }" @click="editor.chain().focus().toggleHeading({ level: 2 }).run()">H2</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('heading', { level: 3 }) }" @click="editor.chain().focus().toggleHeading({ level: 3 }).run()">H3</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive({ textAlign: 'left' }) }" @click="editor.chain().focus().setTextAlign('left').run()">Left</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive({ textAlign: 'center' }) }" @click="editor.chain().focus().setTextAlign('center').run()">Center</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive({ textAlign: 'right' }) }" @click="editor.chain().focus().setTextAlign('right').run()">Right</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('bulletList') }" @click="editor.chain().focus().toggleBulletList().run()">• List</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('orderedList') }" @click="editor.chain().focus().toggleOrderedList().run()">1. List</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('blockquote') }" @click="editor.chain().focus().toggleBlockquote().run()">Quote</button>
      <button type="button" class="toolbar-btn" :class="{ active: editor.isActive('link') }" @click="setLink">Link</button>
      <button type="button" class="toolbar-btn" @click="addImageByUrl">Image URL</button>
      <button type="button" class="toolbar-btn" @click="insertTable">Table</button>
      <button type="button" class="toolbar-btn" :disabled="!editor.can().addColumnAfter()" @click="editor.chain().focus().addColumnAfter().run()">+ Col</button>
      <button type="button" class="toolbar-btn" :disabled="!editor.can().addRowAfter()" @click="editor.chain().focus().addRowAfter().run()">+ Row</button>
      <button type="button" class="toolbar-btn" :disabled="!editor.can().deleteTable()" @click="editor.chain().focus().deleteTable().run()">Del Table</button>
      <label class="toolbar-btn cursor-pointer">
        {{ isUploading ? 'Uploading...' : 'Upload' }}
        <input type="file" accept="image/*" class="hidden" :disabled="isUploading" @change="uploadImage" />
      </label>
      <button type="button" class="toolbar-btn" :disabled="!editor.can().undo()" @click="editor.chain().focus().undo().run()">Undo</button>
      <button type="button" class="toolbar-btn" :disabled="!editor.can().redo()" @click="editor.chain().focus().redo().run()">Redo</button>
    </div>

    <EditorContent :editor="editor" />

    <div class="border-t border-dashed border-slate-200 bg-slate-50 px-4 py-2 text-xs font-semibold text-slate-500">
      Có thể kéo thả ảnh trực tiếp vào vùng soạn thảo. Ảnh sẽ được upload lên backend trước khi chèn vào bài viết.
    </div>
  </div>
</template>

<style scoped>
.toolbar-btn {
  border: 1px solid rgb(226 232 240);
  border-radius: 0.65rem;
  background: white;
  padding: 0.45rem 0.7rem;
  font-size: 0.78rem;
  font-weight: 800;
  color: rgb(51 65 85);
  transition: background-color 150ms ease, color 150ms ease, border-color 150ms ease;
}

.toolbar-btn:hover {
  border-color: rgb(181 211 153);
  background: rgb(244 249 239);
  color: rgb(45 90 39);
}

.toolbar-btn.active {
  border-color: rgb(45 90 39);
  background: rgb(45 90 39);
  color: white;
}

.toolbar-btn:disabled {
  cursor: not-allowed;
  opacity: 0.45;
}

:deep(.tiptap table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
}

:deep(.tiptap th),
:deep(.tiptap td) {
  border: 1px solid rgb(203 213 225);
  padding: 0.65rem;
  vertical-align: top;
}

:deep(.tiptap th) {
  background: rgb(244 249 239);
  color: rgb(45 90 39);
}
</style>
