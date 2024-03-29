require 'ruby2d'
require 'matrix'

set title: 'Game Of Life'
set background: 'black'
set height: 720
set width: 1240
set resizable: true


class Cell
    attr_accessor :size, :fig,:time
    attr_reader :status

    def initialize(x, y, sz, stat)
        @size = sz
        if stat
            @fig = Square.new(
            x: x, y: y,
            size: sz,
            color: 'white',
            z: 10)
        else
            @fig = Square.new(
                x: x, y: y,
                size: sz,
                color: 'black',
                z: 10)
        end

        #true vivo , false muerto
        @status = stat
        @time = 0
    end


    def status=(x)
        @status = x
        if self.status
            self.fig.color = 'white'
        else
            self.fig.color = 'black'
        end
        @status
    end


end


class Grid

    attr_accessor :alive_cells, :grid
    attr_accessor :rows , :columns, :poblation, :generation,:time
    attr_accessor :pobtxt, :gentxt
    def initialize(rsize, csize)
        g = []
        xinit = 10
        y = 30
        for i in 0...rsize do
            xaux = xinit
            f = []
            for j in 0...csize do
                c = Cell.new(xaux, y, 15, false)
                f.append c
                xaux += 15
            end
            g.append f
            y += 15
        end

        @grid = g
        @alive_cells = {}
        @rows = rsize
        @columns = csize
        @poblation = 0
        @generation = 0

        @pobtxt = Text.new(
            'Poblation: '+self.poblation.to_s, x: 10,
            y: 10, size: 15, color:'white'
        )

        @gentxt = Text.new(
            'Generation: '+self.generation.to_s, x: 400,
            y: 10, size: 15, color:'white'
        )

        @time = 0
    end

    #retorna el numero de vecinos vivos
    ##
    # This function calculates the number of neighboring cells with a certain status in a grid.
    #
    # Args:
    #   i: The row index of the cell for which we want to find the number of neighbors.
    #   j: The variable j represents the column index of a cell in a grid.
    #
    # Returns:
    #   The function `vecinos(i,j)` returns the number of neighboring cells that are alive (i.e. have a `status` of
    # `true`) in a grid at position `(i,j)`.
    def vecinos(i,j)
        v = 0 #numero de vecinos
        if i-1 >= 0 and self.grid[i-1][j].status and self.grid[i][j].time == self.grid[i-1][j].time
            v += 1
        end

        if j + 1 < self.columns and self.grid[i][j+1].status and self.grid[i][j].time == self.grid[i][j+1].time
            v += 1
        end

        if i+1 < self.rows and self.grid[i+1][j].status and self.grid[i][j].time == self.grid[i+1][j].time
            v += 1
        end

        if j-1 >= 0 and self.grid[i][j-1].status and self.grid[i][j].time == self.grid[i][j-1].time
            v += 1
        end


        if j + 1 < self.columns and i-1 >= 0 and self.grid[i-1][j+1].status and self.grid[i][j].time == self.grid[i-1][j+1].time
            v+= 1
        end
        if j - 1 >= 0 and i-1 >= 0 and self.grid[i-1][j-1].status and self.grid[i][j].time == self.grid[i-1][j-1].time
            v+= 1
        end

        if j + 1 < self.columns and i+1 < self.rows and self.grid[i+1][j+1].status and self.grid[i][j].time == self.grid[i+1][j+1].time
            v+= 1
        end
        if j - 1  >= 0 and i+1 < self.rows and self.grid[i+1][j-1].status and self.grid[i][j].time == self.grid[i+1][j-1].time
            v+= 1
        end

        return v
    end


    #recibe las posiciones para la primera generacion con un array  que contenga las posiciones
    #de la sig manera[[r1, c1], [r2,c2], ..., [rn, cn]]
    ##
    # This function initializes a grid with a given array of coordinates and updates the population count.
    #
    # Args:
    #   arry: The parameter "arry" is an array of arrays, where each inner array contains two elements representing the x
    # and y coordinates of a cell in a grid. The method "init_generation" uses this array to set the status of the
    # corresponding cells in the grid to true, indicating that they are alive.
    def init_generation(arry)

        for i in 0...arry.length  do
            self.grid[arry[i][0]][arry[i][1]].status = true
            @poblation += 1
        end

        @pobtxt.text = 'Poblation: '+ arry.length.to_s
    end

    #Cuenta la poblacion inicial, en caso de que la generacion 0 se haga con el mouse
    ##
    # This function initializes the population count by iterating through a grid and counting the number of cells with a
    # certain status.
    def init_pob
        for i in 0...self.rows do
            for j in 0...self.columns do
                if self.grid[i][j].status
                    @poblation += 1
                end
            end
        end

        @pobtxt.text = 'Poblation: '+ @poblation.to_s
    end

    #Aplica las reglas del juego y crea la sig. generacion
    ##
    # This function updates the status of each cell in a grid based on the number of live neighbors and updates the
    # population and generation count.
    def next_generation
        ngrid = Matrix.build(self.rows, self.columns) { 0 }
        for i in 0...self.rows do
            for j in 0...self.columns do
                if self.grid[i][j].status
                    #si la celda tiene menos de 2 vecinos vivos muere
                    if self.vecinos(i,j) < 2 then
                        #self.grid[i][j].status = false
                        ngrid[i,j] = 0
                        @poblation -= 1
                    elsif self.vecinos(i,j) >= 4 # si la celda tiene 4 o mas vecinos vivos muere
                        #self.grid[i][j].status = false
                        ngrid[i,j] = 0
                        @poblation -= 1
                    elsif self.vecinos(i,j) >= 2 and self.vecinos(i,j) < 4 #si la celda tiene 2 o 3 vecinos se mantiene
                        #self.grid[i][j].status = true
                        ngrid[i,j] = 1
                    end
                else
                    if self.vecinos(i,j) == 3 # si la celda tiene exactamente 3 vecinos vivos nace

                        #self.grid[i][j].status = true
                        ngrid[i,j] = 1
                        @poblation += 1
                    end
                end

            end

        end
        @pobtxt.text = 'Poblation: '+ @poblation.to_s
        @generation += 1


        for i in 0...self.rows do
            for j in 0...self.columns do
                if ngrid[i,j] == 1 then
                    self.grid[i][j].status = true
                else
                    self.grid[i][j].status = false
                end

                self.grid[i][j].time = self.grid[i][j].time + 1
            end
        end

        @gentxt.text = "Generation: "+ @generation.to_s

    end

    #Determina si el mouse esta en el grid
    ##
    # This function searches for a point (x,y) within a grid and returns the coordinates of the cell containing that
    # point.
    #
    # Args:
    #   x: The x-coordinate of a point in a 2D graph.
    #   y: The parameter `y` is a variable that represents the y-coordinate of a point in a 2D graph.
    #
    # Returns:
    #   The method `in_graph` returns an array with two elements, representing the row and column indices of the grid cell
    # that contains the point (x,y) if it exists in the grid. If the point is not found in the grid, the method returns
    # `nil`.
    def in_graph(x, y)
        for i in 0...self.rows do
            for j in 0...self.columns do
                if self.grid[i][j].fig.contains?  x,y then
                    return [i,j]
                end
            end
        end
        return nil
    end


    ##
    # The "reset" function sets all cells in a grid to false and resets generation and population counts to zero.
    def reset
        for i in 0...self.rows do
            for j in 0...self.columns do
                self.grid[i][j].status = false
            end
        end

        @generation = 0
        @gentxt.text = 0.to_s
        @poblation = 0
        @pobtxt.text = 0.to_s

    end

    def print_g()
        print('gen: ',self.generation)
        for i in 0...self.rows do
            for j in 0...self.columns do
                puts(self.grid[i][j].status, ' {i},{j}',i,j)
            end
            print('-')
        end
    end



end


#x =  Cell.new(10,10,5, false)

#La optimizacion para el reseteo del grid depende del tamaño del grid
#si deseas modificar el tamaño deberas retirar o agregar la posiciones
#faltantes en la parte del reseteo del grid
gr = Grid.new(60,100)
=begin

Si lo deseamos podemos establecer la primer generacion de la sig. manera
haciendo uso del metodo init_generation de la clase grid, pasandole como
argumento las posiciones que queremos que se  enciendan como se  muestra
en el sig. array.
init_grid = [[25,25],[25,26],[24,25], [24, 23], [24,24],
            [15, 4], [15,5] , [15, 6],[16,5], [33, 33],
        [33, 34], [33, 35], [34,34], [34,35], [35, 35]]

gr.init_generation(init_grid)
=end

init_gen = []

#Eventos relacionados con los botones en el mouse
on :mouse_down do |event|

    case event.button
    when :left
        #Con el boton izquierdo comenzamos a generar la sig. generaciones(se debe haber establecido una generacion inicial previamente )
        gr.init_pob
        update do
            gr.next_generation
            #gr.print_g
        end
    when :right
        #podemos marcar una celda unicamente haciendo click derecho sobre la celda que queremos marcar
        #la poblacion y la generacion 0, se ajustan automaticamente usando este metodo.
        #si la celda esta viva(blanca) se vuelve negra(muerta) y visceversa.
        if gr.in_graph(event.x, event.y) != nil
            p = gr.in_graph(event.x, event.y)

            if gr.grid[p[0]][p[1]].status
                gr.grid[p[0]][p[1]].status = false
            else
                gr.grid[p[0]][p[1]].status = true
            end
        end
    else
    end
end

#Eventos relacionados con el teclado
on :key_down do |event|
    if event.key == 'r'
        #resetea el juego, pero es demasiado lento (falta optimizar v:)
        i = 0
        j = 0
        gr.pobtxt.text = 'Poblation: ' + 0.to_s
        gr.gentxt.text = 'Generation: '+ 0.to_s
        gr.generation = 0
        gr.poblation = 0

        update do

            if j < gr.columns
                gr.grid[0][j].status = false
                gr.grid[1][j].status = false
                gr.grid[2][j].status = false
                gr.grid[3][j].status = false
                gr.grid[4][j].status = false
                gr.grid[5][j].status = false
                gr.grid[6][j].status = false
                gr.grid[7][j].status = false
                gr.grid[8][j].status = false
                gr.grid[9][j].status = false

                gr.grid[10][j].status = false
                gr.grid[11][j].status = false
                gr.grid[12][j].status = false
                gr.grid[13][j].status = false
                gr.grid[14][j].status = false
                gr.grid[15][j].status = false
                gr.grid[16][j].status = false
                gr.grid[17][j].status = false
                gr.grid[18][j].status = false
                gr.grid[19][j].status = false

                gr.grid[20][j].status = false
                gr.grid[21][j].status = false
                gr.grid[22][j].status = false
                gr.grid[23][j].status = false
                gr.grid[24][j].status = false
                gr.grid[25][j].status = false
                gr.grid[26][j].status = false
                gr.grid[27][j].status = false
                gr.grid[28][j].status = false
                gr.grid[29][j].status = false

                gr.grid[30][j].status = false
                gr.grid[31][j].status = false
                gr.grid[32][j].status = false
                gr.grid[33][j].status = false
                gr.grid[34][j].status = false
                gr.grid[35][j].status = false
                gr.grid[36][j].status = false
                gr.grid[37][j].status = false
                gr.grid[38][j].status = false
                gr.grid[39][j].status = false

                gr.grid[40][j].status = false
                gr.grid[41][j].status = false
                gr.grid[42][j].status = false
                gr.grid[43][j].status = false
                gr.grid[44][j].status = false
                gr.grid[45][j].status = false
                gr.grid[46][j].status = false
                gr.grid[47][j].status = false
                gr.grid[48][j].status = false
                gr.grid[49][j].status = false

                gr.grid[50][j].status = false
                gr.grid[51][j].status = false
                gr.grid[52][j].status = false
                gr.grid[53][j].status = false
                gr.grid[54][j].status = false
                gr.grid[55][j].status = false
                gr.grid[56][j].status = false
                gr.grid[57][j].status = false
                gr.grid[58][j].status = false
                gr.grid[59][j].status = false
##
                #gr.grid[60][j].status = false
                #gr.grid[61][j].status = false
                #gr.grid[62][j].status = false
                #gr.grid[63][j].status = false
                #gr.grid[64][j].status = false
                #gr.grid[65][j].status = false
                #gr.grid[66][j].status = false
                #gr.grid[67][j].status = false
            end
            j+= 1
        end
    end
end





show
