import type { Meta, StoryObj } from '@storybook/react-vite'
import { AstRenderer } from './AstRenderer'

const sampleNode = {
  type: 'document' as const,
  name: 'dmodule',
  attributes: {},
  xpath: '/',
  children: [
    {
      type: 'element' as const,
      name: 'dmTitle',
      attributes: {},
      xpath: '/dmodule/dmTitle[1]',
      children: [
        {
          type: 'text' as const,
          name: '#text',
          text: 'Sample publication',
          attributes: {},
          xpath: '/dmodule/dmTitle[1]/text()[1]',
          children: []
        }
      ]
    },
    {
      type: 'element' as const,
      name: 'brPara',
      attributes: { id: 'BR-100' },
      xpath: '/dmodule/brPara[1]',
      children: [
        {
          type: 'element' as const,
          name: 'para',
          attributes: {},
          xpath: '/dmodule/brPara[1]/para[1]',
          children: [
            {
              type: 'text' as const,
              name: '#text',
              text: 'Follow',
              attributes: {},
              xpath: '/dmodule/brPara[1]/para[1]/text()[1]',
              children: []
            },
            {
              type: 'element' as const,
              name: 'internalRef',
              attributes: { internalRefId: 'BR-200' },
              xpath: '/dmodule/brPara[1]/para[1]/internalRef[1]',
              children: [
                {
                  type: 'text' as const,
                  name: '#text',
                  text: 'this cross-reference',
                  attributes: {},
                  xpath: '/dmodule/brPara[1]/para[1]/internalRef[1]/text()[1]',
                  children: []
                }
              ]
            }
          ]
        }
      ]
    },
    {
      type: 'element' as const,
      name: 'brPara',
      attributes: { id: 'BR-200' },
      xpath: '/dmodule/brPara[2]',
      children: [
        {
          type: 'element' as const,
          name: 'title',
          attributes: {},
          xpath: '/dmodule/brPara[2]/title[1]',
          children: [
            {
              type: 'text' as const,
              name: '#text',
              text: 'Referenced section',
              attributes: {},
              xpath: '/dmodule/brPara[2]/title[1]/text()[1]',
              children: []
            }
          ]
        }
      ]
    }
  ]
}

const meta = {
  title: 'Renderer/AstRenderer',
  component: AstRenderer,
  args: {
    node: sampleNode
  }
} satisfies Meta<typeof AstRenderer>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {}
