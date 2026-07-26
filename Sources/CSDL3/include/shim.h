#ifndef CSDL3_SHIM_H
#define CSDL3_SHIM_H

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <SDL3_image/SDL_image.h>

#include "clay.h"

void Clay_SDL3_Initialize(SDL_Renderer *renderer, TTF_TextEngine *textEngine, TTF_Font **fonts);
void Clay_SDL3_RenderCommands(Clay_RenderCommandArray *commands, TTF_Font **fonts);

#endif
