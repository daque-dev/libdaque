module daque.graphics.sdl;

import std.string;

import core.stdc.stdlib;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl;

static this()
{
	DerelictSDL2.load(SharedLibVersion(2, 0, 2));
	DerelictSDL2Image.load();

	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) // error initializing SDL2 
	{
		exit(-1);
	}
}
/// Canvas for drawing
class Window
{
public:

	/++
			Constructs a new window with the specified dimensions and name.

			Params:
				name = name of the window to be constructed
				width = width of the window to be constructed
				height = height of the window to be constructed
			+/
	this(string name, uint width, uint height)
	{
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

		m_window = cast(immutable(SDL_Window*)) SDL_CreateWindow(name.toStringz(), SDL_WINDOWPOS_CENTERED,
				SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL);
		m_isOpen = m_window != null;

		m_glContext = SDL_GL_CreateContext(getWindow);

		DerelictGL3.reload();
	}
	/// Closes the window
	~this()
	{
		this.close();
	}
	/// Closes the window if it is open, deallocating it's resources.
	void close()
	{
		if (isOpen())
			SDL_DestroyWindow(getWindow());
		m_isOpen = false;
	}
	/// Tells wether the window is currently open
	bool isOpen()
	{
		return m_isOpen;
	}

	/// Clear window buffer contents
	void clear()
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	/// Prints current buffer contents into screen
	void print()
	{
		SDL_GL_SwapWindow(getWindow);
	}

private:
	/// reference to SDL window representation
	immutable(SDL_Window*) m_window;
	bool m_isOpen;
	/// get non immutable reference to the window
	SDL_Window* getWindow()
	{
		return cast(SDL_Window*) m_window;
	}
	/// SDL-GL context handle
	SDL_GLContext m_glContext;
}


