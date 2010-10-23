#!/usr/bin/env python

""" TicTacToe Engine with NxN grid """

import random

class Tris():
    '''
    versatile tic-tac-toe class, you can set any option and play your own
    game. Quite pr0 stuff :3
    '''

    def __init__(self, dim=3, towin=3, players=("X", "O")):
        '''
        you can set the dimension of the board, the number of pieces in a
        row in order to win and a touple with the players
        '''
        self.players = players
        self.dim = dim
        self.towin = towin
        if self.towin > self.dim:
            raise ValueError("towin can't be greater than dim")
        if self.towin < 3 or self.dim < 3:
            raise ValueError("towin and dim must be greater than 3")
        self.schema = [" " for i in range(self.dim ** 2)]
        self.wr = []
        for i in range(self.dim):
            self.wr.append(range(i * self.dim, (i + 1) * self.dim)) #horiz
            self.wr.append([i + self.dim * j for j in range(self.dim)]) #vert
        for i in range(self.dim - self.towin + 1): #diagonals
            self.wr.append([k * self.dim + i + k for k in range(self.dim - i)])
            self.wr.append([k * (self.dim - 1) - i for k in range(self.dim - i, 0, -1)])
        for i in range(1, self.dim - self.towin + 1):
            self.wr.append([k * self.dim + i * self.dim + k for k in range(self.dim - i)])
            self.wr.append([k * (self.dim - 1) + i * self.dim for k in range(self.dim - i, 0, -1)])
        print self.wr

    def play(self, pos, player):
        ''' play the game '''
        if not player in self.players:
            raise ValueError("Invalid player: %s" % player)
        pos = int(pos) - 1
        if pos > (self.dim ** 2):
            raise ValueError("Invalid position: %s" % str(pos))
        if not self.schema[pos] in self.players:
            self.schema[pos] = player
        return pos

    def get_schema(self):
        ''' returns an ascii board string '''
        out = []
        border = "+" + "-" * (self.dim * 2 - 1) + "+"
        out.append(border)
        for i in range(self.dim):
            out.append("|%s|" % \
                       "|".join(self.schema[i * self.dim:self.dim * (i + 1)]))
        out.append(border)
        return "\n".join(out)

    def get_valid_moves(self):
        ''' returns a list with the possible moves '''
        return [i + 1 for i in range(self.dim ** 2) \
                if not self.schema[i] in self.players]

    def check_winner(self):
        ''' checks if someone won the game '''
        win = False
        for row in self.wr:
            pos = [self.schema[i] for i in row]
            for i in range(len(pos) - self.towin + 1):
                c = pos[i:i + self.towin]
                if c[0] in self.players and c == [c[0]] * len(c):
                    return c[0]

    def ai_play(self, ai, handicap=0):
        '''
        simple AI that plays with you when you feel lonely :)
        TODO:
        - fork
        - block fork option 2
        - now works only with 3x3 grid
        '''
        if not ai in self.players:
            raise ValueError("Invalid AI player name: %s" % ai)
        if not handicap > 0 and not handicap < 100:
            raise ValueError("Handicap value must be between 0 and 100")
        self.ai = ai
        valid = self.get_valid_moves()
        strategy = [self.ai_2_in_a_row,
                    self.ai_center,
                    self.ai_fork,
                    self.ai_block_fork,
                    self.ai_opposite_corner,
                    self.ai_random_corner]
        for func in strategy:
            move = func()
            if move in valid and handicap < random.randint(0, 100):
                return self.play(move, self.ai)
        return self.play(random.choice(valid), self.ai)

    def ai_2_in_a_row(self):
        move = None
        for i, elem in enumerate(self.schema):
            if elem not in self.players:
                for player in self.players:
                    self.schema[i] = player
                    win = self.check_winner()
                    self.schema[i] = " "
                    if win is not None:
                        if win in self.players:
                            if win == self.ai:
                                return i + 1
                            else:
                                move = i + 1
        return move

    def ai_fork(self):
        pass

    def ai_block_fork(self):
        moves = []
        valid = self.get_valid_moves()
        for i, elem in enumerate(self.schema):
            if elem not in self.players:
                self.schema[i] = self.ai
                test = self.ai_2_in_a_row()
                if test is not None and test + 1 in valid:
                    if self.schema[test] not in self.players:
                        self.schema[test] = self.ai
                        if self.check_winner() is not None:
                            moves.append(i)
                        self.schema[test] = " "
                self.schema[i] = " "
        if len(moves) > 0:
            return random.choice(moves)

    def ai_center(self):
        if self.dim % 2 != 0:
            return self.dim ** 2 / 2 + 1

    def ai_opposite_corner(self):
        moves = []
        for row in self.wr:
            pos = [self.schema[i] for i in row]
            for i in range(len(pos) - self.towin + 1):
                a = pos[i:i + self.towin]
                b = a[:]
                b.reverse()
                test = None
                if a[0] in self.players:
                    test = a
                if b[0] in self.players:
                    test = b
                if test is not None and not test[0] == self.ai and \
                        not test[1] in self.players and test[1] == test[2]:
                    moves.append(row[i] + 1)
        if len(moves) > 0:
            return random.choice(moves)

    def ai_random_corner(self):
        valid = self.get_valid_moves()
        move = None
        while not move in valid:
            wr = random.choice(self.wr)
            move = wr[random.choice([-(self.towin - 1), self.towin - 1])] + 1
        return move

if __name__ == "__main__":
    import random
    players = ("X", "A")
    t = Tris(dim=3, towin=3, players=players)
    curr = random.randint(0, len(players) - 1)
    print "=" * 35
    print "Tris by fox (fox91 at anche dot no)"
    print "=" * 35
    print
    print "Player %s starts! Enjoy :D\n" % players[curr]
    try:
        while True:
            print t.get_schema()
            valid = t.get_valid_moves()
            print "Valid moves are: %s" % \
                  ", ".join("%s" % elem for elem in valid)
            if players[curr] == "A":
                t.ai_play("A", 30)
            else:
                move = ""
                while move not in valid:
                    move = raw_input("[Player %s]: " % players[curr])
                    try:
                        move = int(move)
                    except ValueError:
                        print "e...mi prendi in giro? (cit.)"
                t.play(move, players[curr])
            if len(t.get_valid_moves()) == 0:
                print t.get_schema()
                print "No more valid moves: tie!"
                break
            win = t.check_winner()
            if win is not None:
                print t.get_schema()
                print ":O Player %s won! O:" % win
                break
            curr += 1
            curr %= len(players)
    except KeyboardInterrupt:
        print "\nThe prophecy hasn't been fulfilled though maybe you've something better to do"
        print "but remember, the game never ends...\n"
    finally:
        print "\nBai :3"
        raw_input("Press return to continue...")
